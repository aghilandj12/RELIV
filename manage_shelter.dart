import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/screens/shelter_model.dart';

class ManageShelterPage extends StatefulWidget {
  @override
  _ManageShelterPageState createState() => _ManageShelterPageState();
}

class _ManageShelterPageState extends State<ManageShelterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _maxVolunteersController = TextEditingController();

  // Function to add shelter to Firestore
  Future<void> _addShelter() async {
    String name = _nameController.text.trim();
    String address = _addressController.text.trim();
    double latitude = double.tryParse(_latitudeController.text.trim()) ?? 0.0;
    double longitude = double.tryParse(_longitudeController.text.trim()) ?? 0.0;
    int maxVolunteers = int.tryParse(_maxVolunteersController.text.trim()) ?? 0;

    if (name.isEmpty || address.isEmpty || maxVolunteers == 0 || latitude == 0.0 || longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields correctly!")),
      );
      return;
    }

    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    DocumentReference docRef = FirebaseFirestore.instance.collection("shelters").doc();
    Shelter newShelter = Shelter(
      id: docRef.id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      maxVolunteers: maxVolunteers,
    );

    await docRef.set(newShelter.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Shelter added successfully!")),
    );

    // Clear text fields after adding
    _nameController.clear();
    _addressController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _maxVolunteersController.clear();
  }

  // Function to show a confirmation dialog before adding shelter
  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Shelter Addition"),
        content: Text("Are you sure you want to add this shelter?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirm"),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Shelters")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Shelter Name")),
            TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Address")),
            TextField(
              controller: _latitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Latitude"),
            ),
            TextField(
              controller: _longitudeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Longitude"),
            ),
            TextField(
              controller: _maxVolunteersController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Max Volunteers"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addShelter,
              child: const Text("Add Shelter"),
            ),
          ],
        ),
      ),
    );
  }
}
