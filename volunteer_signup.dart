import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VolunteerSignUp extends StatefulWidget {
  @override
  _VolunteerSignUpState createState() => _VolunteerSignUpState();
}

class _VolunteerSignUpState extends State<VolunteerSignUp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool food = false;
  bool shelter = false;
  bool manpower = false;
  bool medicine = false;

  Future<void> registerVolunteer() async {
    try {
      String docId = FirebaseFirestore.instance.collection("volunteers").doc().id;

      await FirebaseFirestore.instance.collection("volunteers").doc(docId).set({
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "gender": _genderController.text.trim(),
        "phone": _phoneController.text.trim(),
        "password": _passwordController.text,
        "address": _addressController.text.trim(),
        "contributions": {
          "food": food,
          "shelter": shelter,
          "manpower": manpower,
          "medicine": medicine,
        },
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Volunteer registered successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget _buildInput(String hint, IconData icon, TextEditingController controller, {bool obscure = false, TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: const UnderlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Checkbox(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ⬅️ Styled Corner Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.teal),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "VOLUNTEER\nREGISTRATION",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              _buildInput("First Name", Icons.person, _firstNameController),
              _buildInput("Last Name", Icons.person, _lastNameController),
              _buildInput("Gender", Icons.female, _genderController),
              _buildInput("Phone Number", Icons.phone, _phoneController, inputType: TextInputType.phone),
              _buildInput("Create Password", Icons.lock, _passwordController, obscure: true),
              _buildInput("Address", Icons.location_on, _addressController),

              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Your contribution",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildCheckbox("Food", food, (val) => setState(() => food = val!)),
              _buildCheckbox("Shelter", shelter, (val) => setState(() => shelter = val!)),
              _buildCheckbox("Man Power", manpower, (val) => setState(() => manpower = val!)),
              _buildCheckbox("Medicine", medicine, (val) => setState(() => medicine = val!)),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: registerVolunteer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("SUBMIT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
