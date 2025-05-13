import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      // Get email from 'users'
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();
      if (userData != null) {
        _emailController.text = userData['email'] ?? '';
      }

      // Get profile data from 'user_profile'
      final profileDoc = await _firestore.collection('user_profile').doc(uid).get();
      final profileData = profileDoc.data();
      if (profileData != null) {
        _nameController.text = profileData['name'] ?? '';
        _addressController.text = profileData['address'] ?? '';
        _districtController.text = profileData['district'] ?? '';
        _languageController.text = profileData['language'] ?? '';
        _mobileController.text = profileData['Mobile'] ?? '';
      }
    }
  }

  Future<void> _saveProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('user_profile').doc(uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'district': _districtController.text.trim(),
        'language': _languageController.text.trim(),
        'Mobile': _mobileController.text.trim(),
      }, SetOptions(merge: true));

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Success"),
            ],
          ),
          content: const Text("Profile updated successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: Icon(Icons.edit, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange.shade300,
                  child: const Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.nightlight_round, color: Colors.black),
                  SizedBox(width: 12),
                  Icon(Icons.wb_sunny, color: Colors.orange),
                ],
              ),
              const SizedBox(height: 20),
              _buildField("Full Name", _nameController),
              _buildField("Email", _emailController),
              _buildField("Address", _addressController),
              _buildField("District", _districtController),
              _buildField("Language", _languageController),
              _buildField("Mobile", _mobileController),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}