import 'package:flutter/material.dart';
import 'package:email_auth/authmanagement/authmanage.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(
              height: 250,
              child: Image.asset("assets/png_images/forgot_pass.png"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Receive an email to reset your password",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Enter Your Registered Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                String? result = await AuthManage().resetPassword(email);

                // Show success/failure message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result ?? "Error")),
                );

                // Redirect to Login after success
                if (result == "Password reset email sent! Check your inbox.") {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("Forgot Password?", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
