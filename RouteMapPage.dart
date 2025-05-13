import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class RouteMapPage extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  const RouteMapPage({super.key, required this.destinationLat, required this.destinationLng});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  LatLng? currentPosition;
  List<LatLng> routePoints = [];
  String distanceText = '';
  String durationText = '';
  String destinationAddress = '';

  final String apiKey = '5b3ce3597851110001cf6248c2deb998851e48c5b4783002e910b528'; // ✅ Safe demo key

  @override
  void initState() {
    super.initState();
    _buildRoute();
  }

  Future<void> _buildRoute() async {
    final pos = await Geolocator.getCurrentPosition();
    currentPosition = LatLng(pos.latitude, pos.longitude);
    final start = '${pos.longitude},${pos.latitude}';
    final end = '${widget.destinationLng},${widget.destinationLat}';

    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=$start&end=$end');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final coords = json['features'][0]['geometry']['coordinates'] as List;

      routePoints = coords
          .map((point) => LatLng(point[1].toDouble(), point[0].toDouble()))
          .toList();

      final props = json['features'][0]['properties']['segments'][0];
      distanceText = (props['distance'] / 1000).toStringAsFixed(2) + ' km';
      durationText = (props['duration'] / 60).toStringAsFixed(0) + ' min';

      await _getAddressFromLatLng(widget.destinationLat, widget.destinationLng);
      setState(() {});
    } else {
      print("Failed to load route: ${response.body}");
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng'),
        headers: {'User-Agent': 'flutter_map_app'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      destinationAddress = data['display_name'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dest = LatLng(widget.destinationLat, widget.destinationLng);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Map"),
        backgroundColor: Colors.teal,
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (distanceText.isNotEmpty || durationText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text('📍 Destination:\n$destinationAddress', textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Text('🛣 Distance: $distanceText'),
                        Text('⏱ ETA: $durationText'),
                      ],
                    ),
                  ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: currentPosition!,
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
                            point: currentPosition!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
                          ),
                          Marker(
                            point: dest,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                          ),
                        ],
                      ),
                      if (routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              strokeWidth: 4,
                              color: Colors.teal,
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
