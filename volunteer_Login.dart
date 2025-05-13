import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/screens/VolunteerHome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerLogin extends StatefulWidget {
  @override
  _VolunteerLoginState createState() => _VolunteerLoginState();
}

class _VolunteerLoginState extends State<VolunteerLogin> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkVolunteerLoginStatus();
  }

  Future<void> _checkVolunteerLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isVolunteerLoggedIn') ?? false;

    if (loggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VolunteerHomePage()));
    }
  }

  Future<void> loginVolunteer() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill both fields")));
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('volunteers')
          .where('phone', isEqualTo: phone)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isVolunteerLoggedIn', true);
        await prefs.setString('volunteerId', doc.id);
        await prefs.setString('volunteerPhone', phone);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const VolunteerHomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid phone or password")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "VOLUNTEER LOGIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 50),
            _buildInputField(
              controller: _phoneController,
              labelText: "Phone Number",
              icon: Icons.phone,
              isObscure: false,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _passwordController,
              labelText: "Password",
              icon: Icons.lock_outline,
              isObscure: true,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: loginVolunteer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8C8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("LOGIN", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required bool isObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF00C8C8)),
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF00C8C8)),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00C8C8), width: 2),
        ),
      ),
    );
  }
}
