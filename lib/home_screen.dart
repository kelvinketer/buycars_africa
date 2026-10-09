import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './detail_screen.dart';

final carsStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Supabase.instance.client
      .from('cars')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BuyCars.Africa'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF232527)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'BuyCars.Africa',
                    style: TextStyle(color: Color(0xFF00E676), fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Kenya's leading digital car marketplace",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.location_on, color: Colors.white),
              title: Text('Ridgeways, Kiambu Road, 00100, KE', style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Colors.white),
              title: Text('0727 025050', style: TextStyle(color: Colors.white)),
            ),
            const ListTile(
              leading: Icon(Icons.access_time, color: Colors.white),
              title: Text('Mon-Fri: 9AM - 5PM\nSat-Sun: 10AM - 2PM', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      body: carsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
        error: (error, _) => Center(child: Text('Failed to load listings:\n$error', style: const TextStyle(color: Colors.white))),
        data: (cars) {
          if (cars.isEmpty) {
            return const Center(child: Text('No vehicles available right now.', style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(carData: car)),
                  );
                },
                child: CarListingCard(carData: car),
              );
            },
          );
        },
      ),
    );
  }
}

// The new Edge-to-Edge UI Component
class CarListingCard extends StatelessWidget {
  final Map<String, dynamic> carData;

  const CarListingCard({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    // Format price with commas (assuming it's a number/string in DB)
    final rawPrice = carData['price']?.toString() ?? '0';
    final price = rawPrice.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    
    // Safely parse image, fallback to placeholder if not yet added to database
    final imageUrl = carData['image_url'] ?? 'https://via.placeholder.com/600x400/232527/FFFFFF?text=No+Image';
    
    // Construct title from Make and Model
    final make = carData['make'] ?? '';
    final model = carData['model'] ?? 'Vehicle Model';
    final carTitle = '$make $model'.trim();

    return Card(
      color: const Color(0xFF232527),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl, 
                height: 220, 
                width: double.infinity, 
                fit: BoxFit.cover
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${carData['year'] ?? ''} • Verified', 
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
                  'KES $price', 
                  style: const TextStyle(color: Color(0xFF00E676), fontSize: 24, fontWeight: FontWeight.w900)
                ),
                const SizedBox(height: 4),
                Text(
                  carTitle, 
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.settings, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(carData['transmission'] ?? 'Auto', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const SizedBox(width: 20),
                    Icon(Icons.local_gas_station, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(carData['fuel_type'] ?? 'Petrol', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                    const Spacer(),
                    Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(carData['hub'] ?? 'Nairobi', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
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