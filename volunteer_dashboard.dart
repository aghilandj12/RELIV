import 'package:flutter/material.dart';

class VolunteerDashboard extends StatelessWidget {
  final String volunteerId; 

  VolunteerDashboard({required this.volunteerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Volunteer Dashboard")),
      body: Center(
        child: Text("Welcome, Volunteer $volunteerId!"),
      ),
    );
  }
}
