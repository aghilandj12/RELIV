import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthManage {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up Function (Already Implemented)
  Future<String?> signUp(String email, String password, String mobile) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store mobile number in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "email": email,
        "mobile": mobile,
      });

      return "User registered successfully!";
    } catch (e) {
      return e.toString();
    }
  }

  // **✅ Sign In Function (Email or Mobile)**
  Future<String?> signIn(String input, String password) async {
    try {
      String email = input;

      // If the input is a mobile number, find the corresponding email
      if (!input.contains("@")) {
        QuerySnapshot userSnapshot = await _firestore
            .collection("users")
            .where("mobile", isEqualTo: input)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          email = userSnapshot.docs.first["email"];
        } else {
          return "user not found!";
        }
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Login successful!";
    } catch (e) {
      return e.toString();
    }
  }

   // 🔹 Forgot Password Function
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return "Password reset email sent! Check your inbox.";
    } catch (e) {
      return e.toString();
    }
  }
}
