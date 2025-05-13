import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmCollectionPage extends StatelessWidget {
  final String notificationId;
  final Map<String, dynamic> data;

  const ConfirmCollectionPage({
    super.key,
    required this.notificationId,
    required this.data,
  });

  Future<void> confirmCollection(BuildContext context) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('notifications').doc(notificationId);
      final notificationDoc = await docRef.get();

      if (!notificationDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Document does not exist!")),
        );
        return;
      }

      await docRef.update({'status': 'collected'});

      final String itemName = data['itemName'];
      final int donatedQty = data['quantity'];

      final goodsSnapshot = await FirebaseFirestore.instance
          .collection('goods')
          .where('name', isEqualTo: itemName)
          .limit(1)
          .get();

      if (goodsSnapshot.docs.isNotEmpty) {
        final goodsDoc = goodsSnapshot.docs.first;
        final currentAvailable = goodsDoc['available'] ?? 0;
        final newAvailable = currentAvailable + donatedQty;

        await goodsDoc.reference.update({'available': newAvailable});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as collected and stock updated!")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔙 Back
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Title
            const Center(
              child: Text(
                "CONFIRM\nPENDING",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),

            /// Card Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Item: ${data['itemName']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Quantity: ${data['quantity']}"),
                    Text("Location: ${data['location']}"),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => confirmCollection(context),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text("Confirm collection", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
