import 'package:flutter/material.dart';

class VolunteerWorkSelectionPage extends StatelessWidget {
  final String shelterName;

  VolunteerWorkSelectionPage({required this.shelterName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose Your Work")),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Shelter: $shelterName", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),

            _buildWorkOption(context, "Manpower (Collecting & Serving)", Icons.handshake, () {}),
            _buildWorkOption(context, "Organizing Goods", Icons.inventory, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
