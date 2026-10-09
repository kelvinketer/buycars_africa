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
        title: const Text('BuyCars.Africa Feed'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'BuyCars.Africa',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
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
              leading: Icon(Icons.location_on),
              title: Text('Ridgeways, Kiambu Road., Kiambu, 00100, KE'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('0727 025050'),
            ),
            const ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Mon-Fri: 9AM - 5PM\nSat-Sun: 10AM - 2PM'),
            ),
          ],
        ),
      ),
      body: carsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load listings:\n$error')),
        data: (cars) {
          if (cars.isEmpty) {
            return const Center(child: Text('No vehicles available right now.'));
          }
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, size: 40, color: Color(0xFF1B5E20)),
                  title: Text('${car['make']} ${car['model']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${car['year']} • ${car['hub'] ?? 'Kiambu Road'}\nKES ${car['price']}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(carData: car)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}