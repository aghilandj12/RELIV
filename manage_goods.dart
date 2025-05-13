import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/models/goods_model.dart';

class ManageGoodsPage extends StatefulWidget {
  @override
  _ManageGoodsPageState createState() => _ManageGoodsPageState();
}

class _ManageGoodsPageState extends State<ManageGoodsPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _neededController = TextEditingController();
  final TextEditingController _availableController = TextEditingController();
  bool _isLoading = false; // Loading state

  // Function to add or update goods in Firestore
  Future<void> _addOrUpdateGood(String? id) async {
    String category = _categoryController.text.trim();
    String name = _nameController.text.trim();
    int needed = int.tryParse(_neededController.text.trim()) ?? 0;
    int available = int.tryParse(_availableController.text.trim()) ?? 0;

    if (category.isEmpty || name.isEmpty || needed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields correctly!")),
      );
      return;
    }

    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      DocumentReference docRef = id == null
          ? FirebaseFirestore.instance.collection("goods").doc()
          : FirebaseFirestore.instance.collection("goods").doc(id);

      Good good = Good(
        id: docRef.id,
        category: category,
        name: name,
        needed: needed,
        available: available,
      );

      await docRef.set(good.toMap());

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      _showSuccessDialog(); // Show acknowledgment

      _categoryController.clear();
      _nameController.clear();
      _neededController.clear();
      _availableController.clear();
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error adding goods: $e")),
      );
    }
  }

  // Function to show a confirmation dialog
  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Action"),
            content: const Text("Are you sure you want to add/update this good?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirm"),
              ),
            ],
          ),
        ) ??
        false;
  }

  // Function to show success acknowledgment
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success ✅"),
        content: const Text("Goods added/updated successfully!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Goods")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Good Name"),
            ),
            TextField(
              controller: _neededController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Needed Quantity"),
            ),
            TextField(
              controller: _availableController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Available Quantity"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // Show loading when saving
                : ElevatedButton(
                    onPressed: () => _addOrUpdateGood(null),
                    child: const Text("Add / Update Good"),
                  ),
          ],
        ),
      ),
    );
  }
}
