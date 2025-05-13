import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';

class ReportDisasterPage extends StatefulWidget {
  @override
  _ReportDisasterPageState createState() => _ReportDisasterPageState();
}

class _ReportDisasterPageState extends State<ReportDisasterPage> {
  final TextEditingController disasterTypeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<String> sendPushNotification(String disasterType, String address) async {
    print("⏳ Starting notification send...");

    int successCount = 0;
    int failureCount = 0;

    try {
      // Step 1: Load service account JSON
      final jsonCredentials = json.decode(await rootBundle.loadString('assets/firebase_key.json'));
      print("✅ Service account loaded");

      final accountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Step 2: Get auth client
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      print("✅ Authenticated with service account");

      final projectId = jsonCredentials['project_id'];

      // Step 3: Get FCM tokens
      final tokensSnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<String> tokens = [];

      for (var doc in tokensSnapshot.docs) {
        if (doc.data().containsKey('fcmToken')) {
          tokens.add(doc.data()['fcmToken']);
        }
      }

      print("📦 Tokens fetched: ${tokens.length}");

      if (tokens.isEmpty) {
        print("⚠️ No FCM tokens found in Firestore.");
        client.close();
        return "No users found with registered tokens.";
      }

      // Step 4: Send notification to each token
      for (String token in tokens) {
        print("🚀 Sending to: $token");

        final response = await client.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "message": {
              "token": token,
              "notification": {
                "title": "🚨 Disaster Alert: $disasterType",
                "body": "Location: $address",
              },
              "android": {
                "priority": "HIGH",
                "notification": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK"
                }
              },
            }
          }),
        );

        if (response.statusCode == 200) {
          print('✅ Notification sent to $token');
          successCount++;
        } else {
          print('❌ Failed to send to $token');
          print('Response: ${response.body}');
          failureCount++;
        }
      }

      client.close();
    } catch (e, stack) {
      print('❌ Exception while sending notifications: $e');
      print('📛 Stack trace:\n$stack');
      return 'Failed to send notifications due to error: $e';
    }

    return "Notifications sent: $successCount success, $failureCount failed.";
  }

  Future<void> reportDisaster() async {
    final disasterType = disasterTypeController.text.trim();
    final address = addressController.text.trim();

    if (disasterType.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      print("📝 Saving disaster to Firestore...");
      await FirebaseFirestore.instance.collection('disasters').add({
        'type': disasterType,
        'address': address,
        'timestamp': DateTime.now(),
      });

      print("📤 Disaster saved. Now sending notifications...");
      String result = await sendPushNotification(disasterType, address);

      Navigator.pop(context); // close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disaster reported!\n$result')),
      );

      disasterTypeController.clear();
      addressController.clear();
    } catch (e) {
      Navigator.pop(context);
      print('❌ Error while reporting disaster: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting disaster: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report Disaster")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: disasterTypeController,
              decoration: InputDecoration(
                labelText: 'Disaster Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Disaster Location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.report_problem),
              label: Text("Submit Report"),
              onPressed: reportDisaster,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
