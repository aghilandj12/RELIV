import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/screens/ShelterGroupChatPage.dart';

class JoinedGroupsPage extends StatefulWidget {
  final String userId;

  const JoinedGroupsPage({super.key, required this.userId});

  @override
  State<JoinedGroupsPage> createState() => _JoinedGroupsPageState();
}

class _JoinedGroupsPageState extends State<JoinedGroupsPage> {
  List<Map<String, dynamic>> joinedShelters = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchJoinedShelters();
  }

  Future<void> fetchJoinedShelters() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("volunteers")
          .doc(widget.userId)
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found.");
      }

      final data = userDoc.data();
      if (data == null || !data.containsKey('joined_groups')) {
        throw Exception("No joined_groups found for user.");
      }

      final List<String> joinedGroupIds = List<String>.from(data['joined_groups']);

      final shelterSnapshot =
          await FirebaseFirestore.instance.collection("shelters").get();

      final matchedShelters = shelterSnapshot.docs
          .where((doc) => joinedGroupIds.contains(doc.id))
          .map((doc) {
        final shelterData = doc.data();
        shelterData['id'] = doc.id;
        return shelterData;
      }).toList();

      setState(() {
        joinedShelters = matchedShelters;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = "Failed to load joined shelters.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // 🔙 Top Bar with Back Button
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
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

            const SizedBox(height: 10),

            // 🧾 Title
            const Center(
              child: Text(
                "YOUR\nGROUPS",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // 📦 Group List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Text(error!))
                      : joinedShelters.isEmpty
                          ? const Center(child: Text("You haven't joined any groups yet."))
                          : ListView.builder(
                              itemCount: joinedShelters.length,
                              itemBuilder: (context, index) {
                                final shelter = joinedShelters[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0FF),
                                      borderRadius: BorderRadius.circular(14),
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
                                        // 🏕 Group Info
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "GROUP: ${shelter['name'] ?? 'Unnamed'}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              "location: ${shelter['location'] ?? 'Unknown'}",
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ],
                                        ),

                                        // 💬 Chat Button
                                        IconButton(
                                          icon: const Icon(Icons.chat_bubble_outline,
                                              color: Colors.blue),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Sheltergroupchatpage(
                                                  groupId: shelter['id'],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
