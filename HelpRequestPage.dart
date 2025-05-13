import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelpRequestPage extends StatelessWidget {
  const HelpRequestPage({super.key});

  final List<String> helpOptions = const [
    "Food", "Aid", "Water", "Shelter", "Manpower"
  ];

  Future<String?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return "Lat: ${position.latitude}, Lng: ${position.longitude}";
  }

  void _sendHelpRequest(BuildContext context, String category) async {
    try {
      final confirmation = await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Confirm Help Request"),
          content: Text("Send request for $category to all volunteers?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text("Confirm"),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirmation != true) return;

      final location = await _getCurrentLocation();
      if (location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied or unavailable.")),
        );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final volunteerId = prefs.getString('volunteerId');
      if (volunteerId == null) throw Exception("Volunteer not logged in.");

      final volunteerDoc = await FirebaseFirestore.instance
          .collection('volunteers')
          .doc(volunteerId)
          .get();

      final senderPhone = volunteerDoc['phone'] ?? 'Volunteer';

      // ✅ Store help request with "reported" status
      await FirebaseFirestore.instance.collection('helpRequests').add({
        'type': category,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'reported',
      });

      // ✅ Send to global volunteer chat
      await FirebaseFirestore.instance
          .collection('volunteerChats')
          .doc('global')
          .collection('messages')
          .add({
        'text': "Urgent help needed: $category at $location",
        'timestamp': FieldValue.serverTimestamp(),
        'senderPhone': senderPhone,
      });

      // ✅ Push to all volunteer tokens
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('volunteerFcmToken', isNotEqualTo: null)
          .get();

      for (var doc in querySnapshot.docs) {
        final token = doc['volunteerFcmToken'];
        if (token != null) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'to': token,
            'title': "Urgent Help Required",
            'body': "Help needed for: $category at $location",
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Help request for $category sent!")),
      );
    } catch (e) {
      print("🔥 Error in help request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while processing the request")),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.redAccent),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "HELP REQUEST",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: helpOptions.length,
                itemBuilder: (context, index) {
                  final option = helpOptions[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: ListTile(
                      title: Text(
                        option,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      onTap: () => _sendHelpRequest(context, option),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
