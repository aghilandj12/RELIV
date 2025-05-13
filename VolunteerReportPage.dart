import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VolunteerReportPage extends StatefulWidget {
  const VolunteerReportPage({Key? key}) : super(key: key);

  @override
  State<VolunteerReportPage> createState() => _VolunteerReportPageState();
}

class _VolunteerReportPageState extends State<VolunteerReportPage> {
  final _distributeItemController = TextEditingController();
  final _distributeQtyController = TextEditingController();
  final _distributeLocationController = TextEditingController();

  final _requestItemController = TextEditingController();
  final _requestQtyController = TextEditingController();
  final _requestLocationController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _sendToGlobalChat(String messageText) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    final senderPhone = userData?['phone'] ?? 'Unknown';

    await _firestore
        .collection('volunteerChats')
        .doc('global')
        .collection('messages')
        .add({
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': user.uid,
      'senderName': senderPhone,
      'senderPhone': senderPhone,
    });
  }

  void _distributeFood() async {
    final item = _distributeItemController.text.trim();
    final qty = _distributeQtyController.text.trim();
    final location = _distributeLocationController.text.trim();

    if (item.isEmpty || qty.isEmpty || location.isEmpty) return;

    final message = "📦 Extra $qty units of $item at $location.";
    await _sendToGlobalChat(message);
    _clearDistributeFields();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Distribution message sent to volunteers!")),
    );
  }

  void _requestFood() async {
    final item = _requestItemController.text.trim();
    final qty = _requestQtyController.text.trim();
    final location = _requestLocationController.text.trim();

    if (item.isEmpty || qty.isEmpty || location.isEmpty) return;

    final message = "📢 Request: $qty units of $item needed at $location.";
    await _sendToGlobalChat(message);
    _clearRequestFields();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Food request message sent to volunteers!")),
    );
  }

  void _clearDistributeFields() {
    _distributeItemController.clear();
    _distributeQtyController.clear();
    _distributeLocationController.clear();
  }

  void _clearRequestFields() {
    _requestItemController.clear();
    _requestQtyController.clear();
    _requestLocationController.clear();
  }

  Widget _buildStyledInput(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required List<Widget> fields,
    required VoidCallback onPressed,
    required Color buttonColor,
    required IconData buttonIcon,
    required String buttonText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...fields,
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              icon: Icon(buttonIcon, color: Colors.white),
              label: Text(buttonText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onPressed,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: ListView(
          children: [
            // 🔙 Back button
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 🧾 Title
            const Center(
              child: Text(
                "VOLUNTEER\nREPORT",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Distribute Section
            _buildReportCard(
              title: "Distribute Remaining Item",
              fields: [
                _buildStyledInput(_distributeItemController, "Item Name"),
                _buildStyledInput(_distributeQtyController, "Quantity"),
                _buildStyledInput(_distributeLocationController, "Location"),
              ],
              onPressed: _distributeFood,
              buttonColor: Colors.green,
              buttonIcon: Icons.send,
              buttonText: "Send Distribution",
            ),

            // 🚨 Request Section
            _buildReportCard(
              title: "Request Item",
              fields: [
                _buildStyledInput(_requestItemController, "Item Name"),
                _buildStyledInput(_requestQtyController, "Quantity"),
                _buildStyledInput(_requestLocationController, "Location"),
              ],
              onPressed: _requestFood,
              buttonColor: Colors.redAccent,
              buttonIcon: Icons.send,
              buttonText: "Send Request",
            ),
          ],
        ),
      ),
    );
  }
}
