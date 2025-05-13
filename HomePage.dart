import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:email_auth/screens/donate.dart';
import 'package:email_auth/screens/HelpRequestPage.dart';
import 'package:email_auth/screens/profile_page.dart';
import 'package:email_auth/screens/signin.dart';
import 'package:email_auth/screens/volunteer_login.dart';
import 'package:email_auth/screens/volunteer_signup.dart';
import 'package:email_auth/screens/SafeZoneSelectionPage.dart';
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final PageController _pageController = PageController(viewportFraction: 0.9);

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppSignInScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error logging out")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        toolbarHeight: 50,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDonationSection(),
            const SizedBox(height: 24),
            _buildDashboardGrid(context),
            const SizedBox(height: 30),
            Align(alignment: Alignment.center, child: _buildHelpButton(context)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 148, 229, 247),
        child: ListView(
          padding: const EdgeInsets.only(top: 60),
          children: [
            const ListTile(
              leading: Icon(Icons.notifications, color: Colors.black),
              title: Text('Notifications', style: TextStyle(color: Colors.black)),
            ),
            const ListTile(
              leading: Icon(Icons.article, color: Colors.black),
              title: Text('News feed', style: TextStyle(color: Colors.black)),
            ),
            const ListTile(
              leading: Icon(Icons.flight, color: Colors.black),
              title: Text('Prepare', style: TextStyle(color: Colors.black)),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline, color: Colors.black),
              title: Text('Help', style: TextStyle(color: Colors.black)),
            ),
            const ListTile(
              leading: Icon(Icons.settings, color: Colors.black),
              title: Text('Settings', style: TextStyle(color: Colors.black)),
            ),
            const ListTile(
              leading: Icon(Icons.group_add, color: Colors.black),
              title: Text('Invite Friends', style: TextStyle(color: Colors.black)),
            ),
            const Divider(color: Colors.black),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Log out', style: TextStyle(color: Colors.black)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Donations",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('urgent_needs')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .get(),
            builder: (context, urgentSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('goods').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final urgentData = urgentSnapshot.data?.docs.first.data() as Map<String, dynamic>? ?? {};
                  final urgentItem = (urgentData['item'] ?? '').toString().toLowerCase();
                  final urgentPlace = urgentData['place'] ?? '';
                  final urgentQty = urgentData['quantity'] ?? '';

                  final docs = snapshot.data!.docs;
                  return Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final name = data['name'] ?? 'Item';
                            final available = data['available'] ?? 0;
                            final needed = data['needed'] ?? 1;
                            final progress = (available / needed).clamp(0.0, 1.0);

                            final isMostUrgentMatch = name.toString().toLowerCase() == urgentItem;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.lightBlue.shade100, Colors.blue.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name.toString().toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 6),
                                  Text("Needed: $needed"),
                                  Text("Available: $available"),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  const SizedBox(height: 8),
                                  if (isMostUrgentMatch)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("⚠ Urgently Needed!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                          Text("Location: $urgentPlace", style: const TextStyle(fontSize: 13)),
                                          Text("Quantity: $urgentQty", style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: docs.length,
                        effect: ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 20,
                          expansionFactor: 4,
                          spacing: 8,
                          activeDotColor: Colors.grey.shade800,
                          dotColor: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.1,
      ),
      children: [
        _dashboardButton(context, label: "Volunteer Registration", icon: Icons.person, color: const Color(0xFFB3E5FC), page: VolunteerSignUp()),
        _dashboardButton(context, label: "Donate", icon: Icons.volunteer_activism, color: const Color(0xFFFFECB3), page: DonatePage()),
        _dashboardButton(context, label: "Login", icon: Icons.login, color: const Color(0xFFC8E6C9), page: VolunteerLogin()),
        _dashboardButton(context, label: "Find Help Nearby", icon: Icons.map_rounded, color: const Color(0xFFFFF9C4), page:  SafeZoneSelectionPage()),
      ],
    );
  }

  Widget _dashboardButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpButton(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          elevation: 4,
          shadowColor: Colors.redAccent.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpRequestPage())),
        child: const Text("HELP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
