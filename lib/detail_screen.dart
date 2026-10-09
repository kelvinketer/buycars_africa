import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> carData;

  const DetailScreen({super.key, required this.carData});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final phone = carData['phone']?.toString().replaceAll(RegExp(r'\s+'), '') ?? '0727025050';
    final intlPhone = phone.startsWith('0') ? '254${phone.substring(1)}' : phone;
    final message = Uri.encodeComponent(
      'Hello BuyCars.Africa, I am inquiring about the ${carData['make']} ${carData['model']} (${carData['year']}) listed for KES ${carData['price']}.',
    );
    final url = Uri.parse('https://wa.me/$intlPhone?text=$message');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${carData['make']} ${carData['model']}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_car, size: 90, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              '${carData['make']} ${carData['model']} (${carData['year']})',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'KES ${carData['price']}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const Divider(height: 32),
            Text('Yard: ${carData['yard'] ?? 'Ridgeways Hub'}'),
            const SizedBox(height: 6),
            Text('Location Hub: ${carData['hub'] ?? 'Kiambu Road'}'),
            const SizedBox(height: 6),
            Text('Contact Line: ${carData['phone'] ?? '0727 025050'}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('Inquire via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _launchWhatsApp(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}