import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routemappage.dart'; // <-- make sure this file exists

class HelpRequestsPage extends StatelessWidget {
  const HelpRequestsPage({super.key});

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _openRoute(BuildContext context, String locationString) {
    final regex = RegExp(r"Lat:\s*([-0-9.]+),\s*Lng:\s*([-0-9.]+)");
    final match = regex.firstMatch(locationString);

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid location format")),
      );
      return;
    }

    final destLat = double.tryParse(match.group(1)!);
    final destLng = double.tryParse(match.group(2)!);

    if (destLat == null || destLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid coordinates")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RouteMapPage(destinationLat: destLat, destinationLng: destLng),
      ),
    );
  }

  Future<void> _takeHelpRequest(BuildContext context, String docId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final volunteerPhone = prefs.getString('volunteerPhone');

      if (volunteerPhone == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Volunteer not logged in")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('helpRequests').doc(docId).update({
        'assignedTo': volunteerPhone,
        'status': 'assigned',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have taken this request.")),
      );
    } catch (e) {
      print("Error assigning request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to take request")),
      );
    }
  }

  Future<void> _completeHelpRequest(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('helpRequests').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request marked as completed and removed.")),
      );
    } catch (e) {
      print("Error deleting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to complete request")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Requests"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF4F9F9),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('helpRequests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No help requests available", style: TextStyle(fontSize: 16)));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'Unknown';
              final location = data['location'] ?? 'Not specified';
              final timestamp = data['timestamp']?.toDate();
              final assignedTo = data['assignedTo'];
              final isAssigned = assignedTo != null;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.help_outline, color: Colors.teal),
                        title: Text("Type: $type", style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Location: $location"),
                            if (timestamp != null)
                              Text(
                                "Requested at: ${_formatTimestamp(timestamp)}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            if (isAssigned)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text("Assigned to: $assignedTo", style: const TextStyle(color: Colors.orange)),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.navigation_rounded, color: Colors.blue),
                          onPressed: () => _openRoute(context, location),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: isAssigned
                            ? TextButton.icon(
                                onPressed: () => _completeHelpRequest(context, doc.id),
                                icon: const Icon(Icons.done, color: Colors.teal),
                                label: const Text("Completed", style: TextStyle(color: Colors.teal)),
                              )
                            : TextButton.icon(
                                onPressed: () => _takeHelpRequest(context, doc.id),
                                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                label: const Text("Take Request", style: TextStyle(color: Colors.green)),
                              ),
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

  String _formatTimestamp(DateTime timestamp) {
    final date = "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    final time = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    return "$date – $time";
  }
}
