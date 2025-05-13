class Shelter {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int maxVolunteers;

  Shelter({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.maxVolunteers,
  });

  // Convert Shelter instance to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'maxVolunteers': maxVolunteers,
    };
  }

  // Create Shelter instance from Firestore data
  factory Shelter.fromMap(String id, Map<String, dynamic> data) {
    return Shelter(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      maxVolunteers: (data['maxVolunteers'] ?? 0).toInt(),
    );
  }
}
