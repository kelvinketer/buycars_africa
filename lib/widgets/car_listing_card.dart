import 'package:flutter/material.dart';

class CarListingCard extends StatelessWidget {
  final Map<String, dynamic> carData;

  const CarListingCard({Key? key, required this.carData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF232527),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Replace with your actual Supabase image column name
              Image.network(
                carData['image_url'] ?? 'https://via.placeholder.com/400', 
                height: 220, 
                width: double.infinity, 
                fit: BoxFit.cover
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${carData['year'] ?? '2018'} • Verified', 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KES ${carData['price']}', 
                  style: const TextStyle(color: Color(0xFF00E676), fontSize: 22, fontWeight: FontWeight.w800)
                ),
                const SizedBox(height: 4),
                Text(
                  carData['model_name'] ?? 'Unknown Model', 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.settings, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(carData['transmission'] ?? 'Auto', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(width: 16),
                    Icon(Icons.local_gas_station, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(carData['fuel_type'] ?? 'Petrol', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(carData['location'] ?? 'Nairobi', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}