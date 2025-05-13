import 'package:flutter/material.dart';

class NearbySuperMarketsAndHotelsPage extends StatelessWidget {
  final String itemName; // Get item donated

  NearbySuperMarketsAndHotelsPage({super.key, required this.itemName});

  final List<Map<String, String>> places = [
    {
      'name': 'Star Supermarket',
      'address': '123 MG Road, Coimbatore',
      'type': 'Supermarket'
    },
    {
      'name': 'Green Park Hotel',
      'address': '45 Avinashi Road, Coimbatore',
      'type': 'Hotel'
    },
    {
      'name': 'Reliance Fresh',
      'address': '88 DB Road, RS Puram',
      'type': 'Supermarket'
    },
    {
      'name': 'The Residency Towers',
      'address': '107, West Club Rd, Coimbatore',
      'type': 'Hotel'
    },
    {
      'name': 'Nilgiris',
      'address': 'Sungam Bypass, Coimbatore',
      'type': 'Supermarket'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text("Nearby Shops & Hotels"),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: Icon(
                place['type'] == 'Hotel' ? Icons.hotel : Icons.local_grocery_store,
                color: Colors.teal,
                size: 30,
              ),
              title: Text(
                place['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(place['address']!),
              trailing: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("📍 Location sent to volunteers from ${place['name']}"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text("Send", style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        },
      ),
    );
  }
}
