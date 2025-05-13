import 'package:flutter/material.dart';
import 'manage_shelter.dart';
import 'manage_goods.dart';
import 'report_disaster.dart';
import 'add_urgent_need.dart';
import 'select_safe_zone_page.dart'; // <-- NEW import (You will create this page)

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFD),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Existing buttons
                        _buildDashboardButton(
                          context,
                          icon: Icons.home_rounded,
                          label: "Manage Shelter",
                          bgColor: const Color(0xFFDFF3FE),
                          iconColor: const Color(0xFF1A73E8),
                          textColor: const Color(0xFF1A73E8),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ManageShelterPage()));
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardButton(
                          context,
                          icon: Icons.inventory_2_outlined,
                          label: "Manage Goods",
                          bgColor: const Color(0xFFE5FFF1),
                          iconColor: const Color(0xFF00A86B),
                          textColor: const Color(0xFF00A86B),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ManageGoodsPage()));
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardButton(
                          context,
                          icon: Icons.warning_amber_rounded,
                          label: "Report Disaster",
                          bgColor: const Color(0xFFFFEAEA),
                          iconColor: const Color(0xFFDA1E28),
                          textColor: const Color(0xFFDA1E28),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDisasterPage()));
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildDashboardButton(
                          context,
                          icon: Icons.priority_high_rounded,
                          label: "Add Urgent Need",
                          bgColor: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFFF6D00),
                          textColor: const Color(0xFFFF6D00),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUrgentNeedPage()));
                          },
                        ),
                        const SizedBox(height: 20),

                        // 🔥 New button: Add Safe Zones
                        _buildDashboardButton(
                          context,
                          icon: Icons.location_on_rounded,
                          label: "Add Safe Zones",
                          bgColor: const Color(0xFFE1F5FE),
                          iconColor: const Color(0xFF0288D1),
                          textColor: const Color(0xFF0288D1),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SelectSafeZonePage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Replace with your logout logic
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
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
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
