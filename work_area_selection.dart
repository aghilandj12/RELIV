import 'package:flutter/material.dart';

class WorkAreaSelectionScreen extends StatefulWidget {
  final String shelterName;

  WorkAreaSelectionScreen({required this.shelterName});

  @override
  _WorkAreaSelectionScreenState createState() => _WorkAreaSelectionScreenState();
}

class _WorkAreaSelectionScreenState extends State<WorkAreaSelectionScreen> {
  String? _selectedWorkArea;

  void _confirmSelection() {
    if (_selectedWorkArea != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You chose to work $_selectedWorkArea at ${widget.shelterName}")),
      );

      // TODO: Store selection in Firestore or local storage if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select where you want to work")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Work Area")),
      body: Column(
        children: [
          ListTile(
            title: Text("Inside Shelter (Food, Medical, Management)"),
            leading: Radio<String>(
              value: "Inside Shelter",
              groupValue: _selectedWorkArea,
              onChanged: (value) {
                setState(() {
                  _selectedWorkArea = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text("Outside Shelter (Transport, Rescue, Guiding)"),
            leading: Radio<String>(
              value: "Outside Shelter",
              groupValue: _selectedWorkArea,
              onChanged: (value) {
                setState(() {
                  _selectedWorkArea = value;
                });
              },
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _confirmSelection,
            child: Text("Confirm Selection"),
          ),
        ],
      ),
    );
  }
}
