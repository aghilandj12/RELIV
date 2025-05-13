class Good {
  final String id;
  final String category; // User-defined category
  final String name;
  final int needed;
  final int available;

  Good({
    required this.id,
    required this.category,
    required this.name,
    required this.needed,
    required this.available,
  });

  // Convert Firestore document to object
  factory Good.fromMap(String id, Map<String, dynamic> data) {
    return Good(
      id: id,
      category: data['category']?.toString() ?? 'Unknown', // Ensure category is a string
      name: data['name']?.toString() ?? '',
      needed: (data['needed'] is int) ? data['needed'] : int.tryParse(data['needed'].toString()) ?? 0,
      available: (data['available'] is int) ? data['available'] : int.tryParse(data['available'].toString()) ?? 0,
    );
  }

  // Convert object to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'category': category, // Now user-defined
      'name': name,
      'needed': needed,
      'available': available,
    };
  }
}
