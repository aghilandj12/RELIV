import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class SafeZoneMapPage extends StatefulWidget {
  final String selectedType; // Shelter, Food, Aid, Emergency

  const SafeZoneMapPage({super.key, required this.selectedType});

  @override
  State<SafeZoneMapPage> createState() => _SafeZoneMapPageState();
}

class _SafeZoneMapPageState extends State<SafeZoneMapPage> {
  Position? currentPosition;
  List<Map<String, dynamic>> safeZones = [];
  final mapController = MapController();
  List<LatLng> routePoints = [];
  String distanceText = '';
  String durationText = '';
  Map<String, dynamic>? nearestSafeZone;

  final String apiKey = '5b3ce3597851110001cf6248c2deb998851e48c5b4783002e910b528'; // your ORS API

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _getCurrentLocation();
    await _fetchSafeZones();
    _findNearestAndRoute();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) await Geolocator.openLocationSettings();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {});
  }

  Future<void> _fetchSafeZones() async {
    final snapshot = await FirebaseFirestore.instance.collection('safe_zones').get();
    final data = snapshot.docs
        .map((doc) => doc.data())
        .where((zone) => zone['type'] == widget.selectedType)
        .toList();

    safeZones = data;
    setState(() {});
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    var dLat = _deg2rad(lat2 - lat1);
    var dLon = _deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c;
    return d;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<void> _findNearestAndRoute() async {
    if (currentPosition == null || safeZones.isEmpty) return;

    double minDist = double.infinity;
    Map<String, dynamic>? nearest;

    for (var zone in safeZones) {
      double dist = _calculateDistance(
        currentPosition!.latitude,
        currentPosition!.longitude,
        zone['latitude'],
        zone['longitude'],
      );
      if (dist < minDist) {
        minDist = dist;
        nearest = zone;
      }
    }

    if (nearest != null) {
      nearestSafeZone = nearest;
      await _buildRoute(
        startLat: currentPosition!.latitude,
        startLng: currentPosition!.longitude,
        endLat: nearest['latitude'],
        endLng: nearest['longitude'],
      );
    }
  }

  Future<void> _buildRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final coords = json['features'][0]['geometry']['coordinates'] as List;

      routePoints = coords.map((point) => LatLng(point[1], point[0])).toList();

      final props = json['features'][0]['properties']['segments'][0];
      distanceText = (props['distance'] / 1000).toStringAsFixed(2) + ' km';
      durationText = (props['duration'] / 60).toStringAsFixed(0) + ' min';

      setState(() {});
    } else {
      print("Failed to load route: ${response.body}");
    }
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
        backgroundColor: Colors.teal,
        title: Text("Nearby ${widget.selectedType} Locations"),
      ),
      body: Column(
        children: [
          if (distanceText.isNotEmpty || durationText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text('🛣 Distance: $distanceText', style: const TextStyle(fontSize: 14)),
                  Text('⏱ ETA: $durationText', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          Expanded(
            child: FlutterMap(
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
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 5,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // User marker
                    Marker(
                      width: 80,
                      height: 80,
                      point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                      child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 50),
                    ),
                    // Nearest SafeZone marker
                    if (nearestSafeZone != null)
                      Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(nearestSafeZone!['latitude'], nearestSafeZone!['longitude']),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
