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
    // Format price with commas
    final rawPrice = carData['price']?.toString() ?? '0';
    final formattedPrice = rawPrice.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    final imageUrl = carData['image_url'] ??
        'https://via.placeholder.com/600x400/232527/FFFFFF?text=No+Image';
    final make = carData['make'] ?? '';
    final model = carData['model'] ?? 'Vehicle Model';
    final carTitle = '$make $model'.trim();
    final year = carData['year']?.toString() ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(carTitle),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image with Overlay Badge
            Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 280,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$year Model',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Pricing and Primary Info
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KES $formattedPrice',
                    style: const TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    carTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Quick Specs Grid
                  Row(
                    children: [
                      _buildSpecTile(
                        icon: Icons.calendar_today,
                        label: 'Year',
                        value: year,
                      ),
                      const SizedBox(width: 12),
                      _buildSpecTile(
                        icon: Icons.settings,
                        label: 'Transmission',
                        value: carData['transmission'] ?? 'Automatic',
                      ),
                      const SizedBox(width: 12),
                      _buildSpecTile(
                        icon: Icons.local_gas_station,
                        label: 'Fuel',
                        value: carData['fuel_type'] ?? 'Petrol',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Dealership & Location Surface
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232527),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location & Dealership',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildLocationRow(
                          icon: Icons.storefront,
                          title: 'Physical Yard',
                          value: carData['yard'] ?? 'Ridgeways Hub',
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildLocationRow(
                          icon: Icons.location_on,
                          title: 'Hub Location',
                          value: carData['hub'] ?? 'Kiambu Road',
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildLocationRow(
                          icon: Icons.phone,
                          title: 'Direct Line',
                          value: carData['phone'] ?? '0727 025050',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 5. Sticky Floating Inquiry Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2022),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text(
              'Inquire via WhatsApp',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _launchWhatsApp(context),
          ),
        ),
      ),
    );
  }

  static Widget _buildSpecTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF232527),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00E676), size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}