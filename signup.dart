import 'package:flutter/material.dart';
import 'package:email_auth/screens/signin.dart';
import 'package:email_auth/authmanagement/authmanage.dart';

class AppSignUpScreen extends StatefulWidget {
  const AppSignUpScreen({Key? key}) : super(key: key);

  @override
  State<AppSignUpScreen> createState() => _AppSignUpScreenState();
}

class _AppSignUpScreenState extends State<AppSignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
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
                  "Create an account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField("Name", Icons.person, _nameController),
              const SizedBox(height: 15),
              _buildInputField("Email", Icons.email, _emailController),
              const SizedBox(height: 15),
              _buildPasswordField("Password", _passwordController),
              const SizedBox(height: 15),
              _buildPasswordField("ConfirmPassword", _confirmPasswordController),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) {
                      setState(() => _rememberMe = val ?? false);
                    },
                  ),
                  const Text("Remember me"),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // TODO: Forgot password logic
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    String name = _nameController.text.trim();
                    String email = _emailController.text.trim();
                    String password = _passwordController.text.trim();
                    String confirmPassword = _confirmPasswordController.text.trim();

                    if (password != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Passwords do not match!")),
                      );
                      return;
                    }

                    String? result = await AuthManage().signUp(email, password, name);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result ?? "Signup failed!")),
                    );

                    if (result == "User registered successfully!") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const AppSignInScreen()),
                      );
                    }
                  },
                  child: const Text("SIGN UP", style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account ? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSignInScreen()));
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Colors.teal),
        suffixIcon: IconButton(
          icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
