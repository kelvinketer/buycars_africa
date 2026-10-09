import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final desktopCarsStream = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Supabase.instance.client
      .from('cars')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);
});

class DealershipPortalScreen extends ConsumerStatefulWidget {
  const DealershipPortalScreen({super.key});

  @override
  ConsumerState<DealershipPortalScreen> createState() => _DealershipPortalScreenState();
}

class _DealershipPortalScreenState extends ConsumerState<DealershipPortalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _yardController = TextEditingController(text: 'Ridgeways Hub');
  final _hubController = TextEditingController(text: 'Kiambu Road');
  final _phoneController = TextEditingController(text: '0727025050');

  String _transmission = 'Automatic';
  String _fuelType = 'Petrol';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _yardController.dispose();
    _hubController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _uploadVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await Supabase.instance.client.from('cars').insert({
        'make': _makeController.text.trim(),
        'model': _modelController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'price': int.parse(_priceController.text.trim().replaceAll(',', '')),
        'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'transmission': _transmission,
        'fuel_type': _fuelType,
        'yard': _yardController.text.trim(),
        'hub': _hubController.text.trim(),
        'phone': _phoneController.text.trim(),
        'isVerified': true,
      });

      _makeController.clear();
      _modelController.clear();
      _yearController.clear();
      _priceController.clear();
      _imageUrlController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00E676),
            content: Text(
              'Vehicle listed successfully! Live on mobile feed & web.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDelete(dynamic id, String carTitle) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF232527),
        title: const Text('Delete Vehicle Listing', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "$carTitle" from live inventory?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await Supabase.instance.client.from('cars').delete().eq('id', id);
    }
  }

  InputDecoration _inputStyle(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 18) : null,
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF1B1D1F),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildUploadForm() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232527),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(22.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_business, color: Color(0xFF00E676), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Add Vehicle to Inventory',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _makeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Make', hint: 'Toyota'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Model', hint: 'Prado TX'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputStyle('Year', hint: '2018'),
                    validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'Invalid year' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputStyle('Price (KES)', hint: '6500000'),
                    validator: (v) => (v == null || int.tryParse(v.trim().replaceAll(',', '')) == null) ? 'Invalid price' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imageUrlController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Image URL', icon: Icons.image_outlined, hint: 'https://...'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _transmission,
                    dropdownColor: const Color(0xFF1E2022),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputStyle('Transmission'),
                    items: ['Automatic', 'Manual'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _transmission = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fuelType,
                    dropdownColor: const Color(0xFF1E2022),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: _inputStyle('Fuel Type'),
                    items: ['Petrol', 'Diesel', 'Hybrid', 'Electric'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (v) => setState(() => _fuelType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _yardController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Yard', icon: Icons.storefront),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _hubController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle('Hub', icon: Icons.location_on),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Contact Phone', icon: Icons.phone),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const SizedBox.shrink()
                    : const Icon(Icons.cloud_upload_outlined, color: Colors.black),
                label: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Publish to Live Feed', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _uploadVehicle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTable(AsyncValue<List<Map<String, dynamic>>> carsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF232527),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Dealership Stock',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              carsAsync.maybeWhen(
                data: (cars) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${cars.length} Active Listings',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: carsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
              error: (err, _) => Center(child: Text('Error loading inventory: $err', style: const TextStyle(color: Colors.redAccent))),
              data: (cars) {
                if (cars.isEmpty) {
                  return const Center(
                    child: Text('No active inventory found. Add your first vehicle using the form.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      horizontalMargin: 12,
                      columnSpacing: 18,
                      headingTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                      dataTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
                      columns: const [
                        DataColumn(label: Text('Vehicle')),
                        DataColumn(label: Text('Year')),
                        DataColumn(label: Text('Price (KES)')),
                        DataColumn(label: Text('Specs')),
                        DataColumn(label: Text('Hub / Yard')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: cars.map((car) {
                        final rawPrice = car['price']?.toString() ?? '0';
                        final formattedPrice = rawPrice.replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        );
                        final carTitle = '${car['make'] ?? ''} ${car['model'] ?? ''}'.trim();
                        final imageUrl = car['image_url'];

                        return DataRow(cells: [
                          DataCell(
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: imageUrl != null && imageUrl.toString().isNotEmpty
                                      ? Image.network(imageUrl, width: 44, height: 32, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _carPlaceholder())
                                      : _carPlaceholder(),
                                ),
                                const SizedBox(width: 10),
                                Text(carTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          DataCell(Text('${car['year'] ?? '—'}')),
                          DataCell(
                            Text(
                              'KES $formattedPrice',
                              style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${car['transmission'] ?? 'Auto'} • ${car['fuel_type'] ?? 'Petrol'}',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ),
                          DataCell(Text('${car['hub'] ?? car['yard'] ?? '—'}')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              tooltip: 'Delete vehicle',
                              onPressed: () => _confirmDelete(car['id'], carTitle),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _carPlaceholder() {
    return Container(
      width: 44,
      height: 32,
      color: Colors.white10,
      child: const Icon(Icons.directions_car, color: Colors.white38, size: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(desktopCarsStream);
    final isCompact = MediaQuery.of(context).size.width < 960;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('BuyCars.Africa — Dealership Stock Portal'),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Feed',
            onPressed: () => ref.refresh(desktopCarsStream),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isCompact
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUploadForm(),
                    const SizedBox(height: 16),
                    SizedBox(height: 500, child: _buildInventoryTable(carsAsync)),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 420,
                    child: SingleChildScrollView(child: _buildUploadForm()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInventoryTable(carsAsync),
                  ),
                ],
              ),
      ),
    );
  }
}