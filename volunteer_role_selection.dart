import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/screens/volunteer_dashboard.dart';

class VolunteerRoleSelectionPage extends StatelessWidget {
  final String volunteerId;
  final String shelterId;
  final String shelterName;

  VolunteerRoleSelectionPage({required this.volunteerId, required this.shelterId, required this.shelterName});

  void _assignRole(BuildContext context, String role) async {
    await FirebaseFirestore.instance.collection("volunteers").doc(volunteerId).set({
      "shelterId": shelterId,
      "shelterName": shelterName,
      "role": role,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Role assigned successfully!")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VolunteerDashboard(volunteerId: volunteerId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Role")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Where would you like to help?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _assignRole(context, "Inside (Managing Food & People)"),
              child: Text("Inside Shelter"),
            ),
            ElevatedButton(
              onPressed: () => _assignRole(context, "Outside (Collecting & Serving Donations)"),
              child: Text("Outside Shelter"),
            ),
          ],
        ),
      ),
    );
  }
}
