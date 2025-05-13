import 'package:email_auth/screens/ShelterGroupChatPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShelterListPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const Center(
              child: Text(
                "SAFE ZONES",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('shelters').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error fetching data"));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No shelters available"));
                  }

                  List<Shelter> shelters = snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return Shelter(
                      id: doc.id,
                      name: data['name'] ?? 'Unknown Shelter',
                      address: data['address'] ?? 'Unknown Location',
                      maxVolunteers: data['maxVolunteers'] ?? 0,
                      location: LatLng(data['latitude'] ?? 0.0, data['longitude'] ?? 0.0),
                    );
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: shelters.length,
                    itemBuilder: (context, index) {
                      return ShelterCard(shelter: shelters[index]);
                    },
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

class ShelterCard extends StatelessWidget {
  final Shelter shelter;

  const ShelterCard({Key? key, required this.shelter}) : super(key: key);

  void _showMap(BuildContext context, LatLng location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[300],
      builder: (context) => SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(initialCenter: location, initialZoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
                  width: 50.0,
                  height: 50.0,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinGroup(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in first")));
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('volunteers').doc(currentUser.uid);
    final userSnapshot = await userDoc.get();
    final shelterId = shelter.id;

    if (userSnapshot.exists) {
      final data = userSnapshot.data() as Map<String, dynamic>;
      final currentGroups = List<String>.from(data['joined_groups'] ?? []);
      if (!currentGroups.contains(shelterId)) {
        currentGroups.add(shelterId);
        await userDoc.update({'joined_groups': currentGroups});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Joined group successfully")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Already joined this group")));
      }
    } else {
      await userDoc.set({'joined_groups': [shelterId]});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Joined group successfully")));
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Sheltergroupchatpage(groupId: shelterId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, size: 28, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shelter.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Location: ${shelter.address}", style: const TextStyle(fontSize: 13)),
                      Text("Max Volunteers: ${shelter.maxVolunteers}", style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _joinGroup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Join Group", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () => _showMap(context, shelter.location),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Direction", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Shelter {
  final String id;
  final String name;
  final String address;
  final int maxVolunteers;
  final LatLng location;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.maxVolunteers,
    required this.location,
  });
}
