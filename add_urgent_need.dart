import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUrgentNeedPage extends StatelessWidget {
  const AddUrgentNeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController placeController = TextEditingController();
    final TextEditingController itemController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Urgent Need"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Urgent Resource Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),

            // Place input
            TextField(
              controller: placeController,
              decoration: const InputDecoration(
                labelText: "Place / Location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Item input
            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: "Item Needed",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity input
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.priority_high_rounded),
                label: const Text(
                  "Submit Urgent Need",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  final place = placeController.text.trim();
                  final item = itemController.text.trim();
                  final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

                  if (place.isEmpty || item.isEmpty || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields correctly.")),
                    );
                    return;
                  }

                  try {
                    await FirebaseFirestore.instance.collection('urgent_needs').add({
                      'place': place,
                      'item': item,
                      'quantity': quantity,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Urgent need added successfully.")),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}