import 'package:flutter/material.dart';
import 'safe_zone_map_page.dart'; // <-- new page we will create next

class SafeZoneSelectionPage extends StatelessWidget {
  const SafeZoneSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Find Nearby Help"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionButton(context, "Shelter", Icons.home_rounded, Colors.blue),
              const SizedBox(height: 20),
              _buildOptionButton(context, "Aid", Icons.volunteer_activism_rounded, Colors.purple),
              const SizedBox(height: 20),
              _buildOptionButton(context, "Food", Icons.fastfood_rounded, Colors.green),
              const SizedBox(height: 20),
              _buildOptionButton(context, "Emergency", Icons.fire_truck, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SafeZoneMapPage(selectedType: label),
          ),
        );
      },
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
