import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/authmanagement/auth_servide.dart';
import 'package:email_auth/authmanagement/authmanage.dart';
import 'package:email_auth/screens/HomePage.dart';
import 'package:email_auth/screens/AdminDashboardPage.dart';
import 'package:email_auth/screens/signup.dart';
import 'package:email_auth/screens/forgot_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSignInScreen extends StatefulWidget {
  const AppSignInScreen({Key? key}) : super(key: key);

  @override
  State<AppSignInScreen> createState() => _AppSignInScreenState();
}

class _AppSignInScreenState extends State<AppSignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  final String adminEmail = "admin@example.com";
  final String adminPassword = "Admin@123";

  Future<void> saveUserDetailsToFirestore(User user) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'role': 'user',
      'fcmToken': token,
    }, SetOptions(merge: true));
  }

  Future<void> setLoginStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      Image.asset("assets/png_images/logo.png", height: 120),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 146, 212, 247)),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter your email" : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 146, 212, 247)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter your password" : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val ?? false),
                    ),
                    const Text("Remember me"),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9F2FF), // THEME COLOR
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("LOGIN", style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account ? "),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSignUpScreen())),
                      child: const Text("Sign Up", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email == adminEmail && password == adminPassword) {
        await setLoginStatus(true);
        _showDialog("Success", "Admin login successful!", isSuccess: true, redirectToAdmin: true);
        return;
      }

      String? result = await AuthManage().signIn(email, password);
      if (result == "Login successful!") {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await saveUserDetailsToFirestore(user);
          await setLoginStatus(true);
          _showDialog("Success", "Login successful!", isSuccess: true);
        }
      } else {
        _showDialog("Error", result ?? "Login failed!", isSuccess: false);
      }
    }
  }

  void _showDialog(String title, String message, {bool isSuccess = false, bool redirectToAdmin = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              if (isSuccess && redirectToAdmin) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboardPage()));
              } else if (isSuccess) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}