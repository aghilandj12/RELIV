import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';

class SafeZoneMapPage extends StatefulWidget {
  final String selectedType;
  const SafeZoneMapPage({super.key, required this.selectedType});

  @override
  State<SafeZoneMapPage> createState() => _SafeZoneMapPageState();
}

class _SafeZoneMapPageState extends State<SafeZoneMapPage> {
  Position? currentPosition;
  List<Map<String, dynamic>> safeZones = [];
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchSafeZones();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  Future<void> _fetchSafeZones() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('safe_zones').get();
    final data = querySnapshot.docs.map((doc) => doc.data()).where((zone) => zone['type'] == widget.selectedType).toList();

    setState(() {
      safeZones = data;
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the earth in km
    var dLat = _deg2rad(lat2 - lat1);
    var dLon = _deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text("Nearby ${widget.selectedType} Locations"),
        backgroundColor: Colors.teal,
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80,
                height: 80,
                point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 50),
              ),
              ...safeZones.map((zone) {
                return Marker(
                  width: 80,
                  height: 80,
                  point: LatLng(zone['latitude'], zone['longitude']),
                  child: Column(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
                      Container(
                        padding: const EdgeInsets.all(2),
                        color: Colors.white,
                        child: Text(
                          "${_calculateDistance(currentPosition!.latitude, currentPosition!.longitude, zone['latitude'], zone['longitude']).toStringAsFixed(2)} km",
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
