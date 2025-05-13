import 'package:flutter/material.dart';
import 'select_location_page.dart'; // <-- Your location picking page

class SelectSafeZonePage extends StatelessWidget {
  const SelectSafeZonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Add Safe Zone"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Choose a Zone to Add",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 32),

                // Safe Shelter Button
                _buildSafeZoneButton(
                  context,
                  icon: Icons.home_rounded,
                  label: "Safe Shelter",
                  bgColor: const Color(0xFFDFF3FE),
                  iconColor: const Color(0xFF1A73E8),
                  zoneType: "Shelter", // <-- pass the zone type
                ),
                const SizedBox(height: 20),

                // Food Distribution Point Button
                _buildSafeZoneButton(
                  context,
                  icon: Icons.food_bank_rounded,
                  label: "Food Distribution Point",
                  bgColor: const Color(0xFFE8F5E9),
                  iconColor: const Color(0xFF43A047),
                  zoneType: "Food",
                ),
                const SizedBox(height: 20),

                // Hospital Button
                _buildSafeZoneButton(
                  context,
                  icon: Icons.local_hospital_rounded,
                  label: "Hospital",
                  bgColor: const Color(0xFFFFEBEE),
                  iconColor: const Color(0xFFD32F2F),
                  zoneType: "Hospital",
                ),
                const SizedBox(height: 20),

                // Emergency Service Button
                _buildSafeZoneButton(
                  context,
                  icon: Icons.fire_truck,
                  label: "Emergency Service",
                  bgColor: const Color(0xFFFFF8E1),
                  iconColor: const Color(0xFFF57F17),
                  zoneType: "Emergency",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafeZoneButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required String zoneType, // <-- Corrected here (not collection name)
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SelectLocationPage(zoneType: zoneType),
          ),
        );
      },
      child: Container(
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
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
