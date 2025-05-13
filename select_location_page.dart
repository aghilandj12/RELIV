import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectLocationPage extends StatefulWidget {
  final String zoneType; // <-- NEW: which type (Shelter, Food, Hospital, Emergency)

  const SelectLocationPage({super.key, required this.zoneType});

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  LatLng? selectedLocation;
  final TextEditingController _nameController = TextEditingController();

  Future<void> _saveLocation() async {
    if (selectedLocation == null || _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please select a location and enter a name')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('safe_zones').add({
        'name': _nameController.text.trim(),
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'type': widget.zoneType, // <-- NEW: saving the type
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Safe Zone Saved Successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Safe Zone"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(11.0168, 76.9558),
                initialZoom: 13.0,
                onTap: (tapPosition, latlng) {
                  setState(() {
                    selectedLocation = latlng;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (selectedLocation != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "📍 Selected Location:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text("Latitude: ${selectedLocation!.latitude}"),
                  Text("Longitude: ${selectedLocation!.longitude}"),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Enter Place Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _saveLocation,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text("Save Location"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
