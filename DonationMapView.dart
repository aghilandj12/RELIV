import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class DonationMapPage extends StatefulWidget {
  final double donorLat;
  final double donorLng;

  const DonationMapPage({
    Key? key,
    required this.donorLat,
    required this.donorLng,
  }) : super(key: key);

  @override
  State<DonationMapPage> createState() => _DonationMapPageState();
}

class _DonationMapPageState extends State<DonationMapPage> {
  LatLng? _volunteerLatLng;
  List<LatLng> _routePoints = [];
  String _distanceText = '';
  String _durationText = '';

  final String _apiKey = '5b3ce3597851110001cf6248c2deb998851e48c5b4783002e910b528';

  @override
  void initState() {
    super.initState();
    _fetchLocationAndRoute();
  }

  Future<void> _fetchLocationAndRoute() async {
    // Get current volunteer location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng volunteer = LatLng(position.latitude, position.longitude);
    setState(() {
      _volunteerLatLng = volunteer;
    });

    // Construct ORS API URL
    final start = '${volunteer.longitude},${volunteer.latitude}';
    final end = '${widget.donorLng},${widget.donorLat}';
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$_apiKey&start=$start&end=$end',
    );

    // Make request
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List;
      final distance = data['features'][0]['properties']['segments'][0]['distance']; // meters
      final duration = data['features'][0]['properties']['segments'][0]['duration']; // seconds

      setState(() {
        _routePoints = coords
            .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
        _distanceText = (distance / 1000).toStringAsFixed(2) + ' km';
        _durationText = (duration / 60).toStringAsFixed(0) + ' min';
      });
    } else {
      print("Failed to load route: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorLatLng = LatLng(widget.donorLat, widget.donorLng);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation Route"),
        backgroundColor: Colors.teal,
      ),
      body: _volunteerLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _volunteerLatLng!,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _volunteerLatLng!,
                      child: const Icon(Icons.person_pin_circle, size: 40, color: Colors.blue),
                    ),
                    Marker(
                      width: 40,
                      height: 40,
                      point: donorLatLng,
                      child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                    ),
                  ],
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.green,
                      ),
                    ],
                  ),
              ],
            ),
      bottomNavigationBar: _distanceText.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.teal[50],
              child: Text(
                "Distance: $_distanceText | ETA: $_durationText",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }
}
