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
  final _yardController = TextEditingController(text: 'Ridgeways Hub');
  final _hubController = TextEditingController(text: 'Kiambu Road');
  final _phoneController = TextEditingController(text: '0727025050');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
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
        'price': int.parse(_priceController.text.trim()),
        'yard': _yardController.text.trim(),
        'hub': _hubController.text.trim(),
        'phone': _phoneController.text.trim(),
        'isVerified': true,
      });

      _makeController.clear();
      _modelController.clear();
      _yearController.clear();
      _priceController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle listed successfully! Live on all platforms.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteVehicle(dynamic id) async {
    await Supabase.instance.client.from('cars').delete().eq('id', id);
  }

  Widget _buildUploadForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const Text('Upload New Vehicle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(controller: _makeController, decoration: const InputDecoration(labelText: 'Make')),
              TextFormField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model')),
              TextFormField(controller: _yearController, decoration: const InputDecoration(labelText: 'Year'), keyboardType: TextInputType.number),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price (KES)'), keyboardType: TextInputType.number),
              TextFormField(controller: _yardController, decoration: const InputDecoration(labelText: 'Yard Name')),
              TextFormField(controller: _hubController, decoration: const InputDecoration(labelText: 'Hub / Location')),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Contact Phone')),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                onPressed: _isSubmitting ? null : _uploadVehicle,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Add to Live Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryTable(AsyncValue<List<Map<String, dynamic>>> carsAsync) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: carsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (cars) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Vehicle')),
                DataColumn(label: Text('Year')),
                DataColumn(label: Text('Price (KES)')),
                DataColumn(label: Text('Hub')),
                DataColumn(label: Text('Actions')),
              ],
              rows: cars.map((car) {
                return DataRow(cells: [
                  DataCell(Text('${car['make']} ${car['model']}')),
                  DataCell(Text('${car['year']}')),
                  DataCell(Text('${car['price']}')),
                  DataCell(Text('${car['hub']}')),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteVehicle(car['id']),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(desktopCarsStream);
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BuyCars.Africa — Dealership Stock Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: isMobile
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUploadForm(),
                  _buildInventoryTable(carsAsync),
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 380,
                  child: _buildUploadForm(),
                ),
                Expanded(
                  child: _buildInventoryTable(carsAsync),
                ),
              ],
            ),
    );
  }
}