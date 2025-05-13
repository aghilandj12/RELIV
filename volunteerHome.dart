import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/screens/JoinedGroupsScreen.dart';
import 'package:email_auth/screens/NotificationsPage.dart';
import 'package:email_auth/screens/ShelterListPage.dart';
import 'package:email_auth/screens/HomePage.dart';
import 'package:email_auth/screens/VolunteerGroupChatPage.dart';
import 'package:email_auth/screens/VolunteerReportPage.dart';
import 'package:email_auth/screens/HelpRequestsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerHomePage extends StatelessWidget {
  const VolunteerHomePage({Key? key}) : super(key: key);

  Future<void> _logoutAsVolunteer(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isVolunteerLoggedIn', false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  HomePage()));
  }

  Widget _roundIcon(IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        actions: [
          _roundIcon(Icons.message, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const VolunteerGroupChatPage()));
          }),
          _roundIcon(Icons.assignment, Colors.teal, () { // ✅ REPLACED HELP ICON
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpRequestsPage()));
          }),
          _roundIcon(Icons.logout, Colors.red, () => _logoutAsVolunteer(context)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('goods').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unknown';
              final needed = data['needed'] ?? 0;
              final available = data['available'] ?? 0;
              final progress = needed == 0 ? 0.0 : (available / needed).clamp(0.0, 1.0);

              Color progressColor;
              if (progress < 0.3) {
                progressColor = Colors.red;
              } else if (progress < 0.7) {
                progressColor = Colors.orange;
              } else {
                progressColor = Colors.green;
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Needed: $needed  Available: $available"),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.map, color: Colors.green),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ShelterListPage()));
              },
            ),
            label: "Shelters",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
              },
            ),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) =>  HomePage()));
              },
            ),
            label: "Main Home",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.mail, color: Colors.orange),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => JoinedGroupsPage(userId: user.uid)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not logged in")),
                  );
                }
              },
            ),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.note, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VolunteerReportPage()),
                );
              },
            ),
            label: "Report",
          ),
        ],
      ),
    );
  }
}
