import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_auth/screens/DonationMapView.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<void> _takeDonation(String docId) async {
    final prefs = await SharedPreferences.getInstance();
    final volunteerPhone = prefs.getString('volunteerPhone');

    if (volunteerPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Volunteer not logged in")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('notifications').doc(docId).update({
        'status': 'assigned',
        'assignedTo': volunteerPhone,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have taken this donation request.")),
      );
    } catch (e) {
      print("Error taking donation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to take request: $e")),
      );
    }
  }

  Future<void> _completeDonation(String docId, String itemName, int quantity) async {
    try {
      final goodsQuery = await FirebaseFirestore.instance
          .collection('goods')
          .where('name', isEqualTo: itemName)
          .limit(1)
          .get();

      if (goodsQuery.docs.isNotEmpty) {
        final goodsDoc = goodsQuery.docs.first;
        final currentAvailable = goodsDoc['available'] ?? 0;

        await FirebaseFirestore.instance
            .collection('goods')
            .doc(goodsDoc.id)
            .update({'available': currentAvailable + quantity});
      } else {
        throw Exception("Item '$itemName' not found in goods.");
      }

      await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation confirmed. Goods updated.")),
      );
    } catch (e) {
      print("Error completing donation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to complete donation: $e")),
      );
    }
  }

  void _navigateToMap(BuildContext context, Map<String, dynamic> data) {
    if (data.containsKey('latitude') && data.containsKey('longitude')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonationMapPage(
            donorLat: data['latitude'],
            donorLng: data['longitude'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donor location not available")),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final date = "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    final time = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    return "$date – $time";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        title: const Text("Donation Requests"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('donatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No donations found."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              if (status != 'pending' && status != 'assigned') return Container();

              final type = data['itemName'] ?? 'Unknown';
              final quantityStr = data['quantity']?.toString() ?? '0';
              final quantity = int.tryParse(quantityStr) ?? 0;
              final assignedTo = data['assignedTo'];
              final lat = data['latitude']?.toStringAsFixed(6) ?? 'N/A';
              final lng = data['longitude']?.toStringAsFixed(3) ?? 'N/A';

              final rawTimestamp = data['donatedAt'];
              DateTime? timestamp;

              if (rawTimestamp is Timestamp) {
                timestamp = rawTimestamp.toDate();
              } else if (rawTimestamp is String) {
                timestamp = DateTime.tryParse(rawTimestamp);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Item: $type", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text("Quantity: $quantityStr", style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.teal),
                          const SizedBox(width: 6),
                          Expanded(child: Text("Lat: $lat, Lng: $lng")),
                          IconButton(
                            icon: const Icon(Icons.navigation_rounded, color: Colors.blue),
                            onPressed: () => _navigateToMap(context, data),
                          ),
                        ],
                      ),

                      if (timestamp != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Requested at: ${_formatTimestamp(timestamp)}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),

                      const SizedBox(height: 10),

                      if (assignedTo == null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _takeDonation(doc.id),
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            label: const Text("Take Request", style: TextStyle(color: Colors.green)),
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Assigned to: $assignedTo",
                              style: const TextStyle(color: Colors.orange),
                            ),
                            TextButton.icon(
                              onPressed: () => _completeDonation(doc.id, type, quantity),
                              icon: const Icon(Icons.done_all_rounded, color: Colors.teal),
                              label: const Text("Mark Completed", style: TextStyle(color: Colors.teal)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
