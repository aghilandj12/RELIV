// DonationDetailPage.dart

import 'dart:convert';
import 'package:email_auth/screens/NearbyHotelsPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DonationDetailPage extends StatefulWidget {
  final String itemName;
  final int currentValue;
  final int maxValue;

  const DonationDetailPage({
    Key? key,
    required this.itemName,
    required this.currentValue,
    required this.maxValue,
  }) : super(key: key);

  @override
  _DonationDetailPageState createState() => _DonationDetailPageState();
}

class _DonationDetailPageState extends State<DonationDetailPage> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  LatLng? _currentLatLng;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _currentLatLng = LatLng(position.latitude, position.longitude);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks.first;

    setState(() {
      _locationController.text =
          '${place.locality}, ${place.administrativeArea}, ${place.country}';
    });
  }

  Future<String> sendVolunteerNotification(String itemName, int quantity, String location) async {
    try {
      final credentialsJson = json.decode(await rootBundle.loadString('assets/firebase_key.json'));
      final serviceAccount = ServiceAccountCredentials.fromJson(credentialsJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final authClient = await clientViaServiceAccount(serviceAccount, scopes);
      final projectId = credentialsJson['project_id'];

      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      final List<String> volunteerTokens = usersSnapshot.docs
          .map((doc) => doc.data()['volunteerFcmToken'])
          .where((token) => token != null && token.toString().isNotEmpty)
          .cast<String>()
          .toList();

      if (volunteerTokens.isEmpty) return 'No volunteer tokens found.';

      int success = 0, fail = 0;
      for (String token in volunteerTokens) {
        final response = await authClient.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "message": {
              "token": token,
              "notification": {
                "title": "📦 New Donation Received!",
                "body": "$quantity $itemName donated at $location"
              },
              "android": {
                "priority": "high",
                "notification": {"click_action": "FLUTTER_NOTIFICATION_CLICK"}
              }
            }
          }),
        );

        if (response.statusCode == 200) {
          success++;
        } else {
          fail++;
          debugPrint("❌ Failed to notify $token: ${response.body}");
        }
      }

      authClient.close();
      return 'Notifications sent: $success success, $fail failed.';
    } catch (e) {
      debugPrint("🔥 Error sending notifications: $e");
      return 'Failed to send notifications: $e';
    }
  }

  void donate() async {
    final User? user = auth.currentUser;
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final String location = _locationController.text.trim();

    if (user != null && quantity > 0 && location.isNotEmpty && _currentLatLng != null) {
      try {
        final donationData = {
          'itemName': widget.itemName,
          'quantity': quantity,
          'location': location,
          'latitude': _currentLatLng!.latitude,
          'longitude': _currentLatLng!.longitude,
          'status': 'pending',
          'assignedTo': null, // ✅ added field
          'donatedAt': FieldValue.serverTimestamp(), // ✅ corrected
          'userId': user.uid,
        };

        await firestore.collection('notifications').add(donationData);

        final msg = await sendVolunteerNotification(widget.itemName, quantity, location);

        _quantityController.clear();
        _locationController.clear();
        Navigator.pop(context);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Success")
              ],
            ),
            content: const Text("Donation submitted!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Text("OK"),
              )
            ],
          ),
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 10),
                Text("Error")
              ],
            ),
            content: Text("Sorry! ${e.toString()}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly.")),
      );
    }
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: const BoxDecoration(
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
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "DONATE\n${widget.itemName.toUpperCase()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Needed: ${widget.maxValue}    Available: ${widget.currentValue}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),
              _buildInput("Enter Quantity", Icons.scale, _quantityController, keyboardType: TextInputType.number),
              _buildInput("Select Location", Icons.location_on, _locationController),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: const Text("Current Location", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_currentLatLng != null)
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentLatLng!,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.email_auth',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLatLng!,
                            child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: donate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text("Donate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    const Text("OR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NearbySuperMarketsAndHotelsPage(itemName: widget.itemName),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text("Donate by Paying", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
