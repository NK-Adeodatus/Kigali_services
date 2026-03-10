import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../models/listing_model.dart';
import '../widgets/ui_helpers.dart';

class AddListingScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const AddListingScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  final _mapController = MapController();
  String _category = 'Hospital';
  late double _previewLat;
  late double _previewLng;

  @override
  void initState() {
    super.initState();
    _previewLat = widget.initialLat ?? -1.9441;
    _previewLng = widget.initialLng ?? 30.0619;
    _latController = TextEditingController(text: _previewLat.toStringAsFixed(6));
    _lngController = TextEditingController(text: _previewLng.toStringAsFixed(6));
    _latController.addListener(_updateMapPreview);
    _lngController.addListener(_updateMapPreview);
  }

  void _updateMapPreview() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      setState(() {
        _previewLat = lat;
        _previewLng = lng;
      });
      _mapController.move(LatLng(lat, lng), 15.0);
    }
  }

  @override
  void dispose() {
    _latController.removeListener(_updateMapPreview);
    _lngController.removeListener(_updateMapPreview);
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.storefront_rounded),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              dropdownColor: kSurface2,
              style: GoogleFonts.dmSans(color: kCream),
              items: [
                'Hospital',
                'Police Station',
                'Library',
                'Restaurant',
                'Café',
                'Park',
                'Tourist Attraction',
              ]
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(kCategoryIcon(c),
                                size: 16, color: kCategoryColor(c)),
                            const SizedBox(width: 8),
                            Text(c),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location_rounded),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.explore_rounded),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Location Preview',
                style: GoogleFonts.dmSans(fontSize: 12, color: kMuted)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_previewLat, _previewLng),
                    initialZoom: 15,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.kigali_city_services',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_previewLat, _previewLng),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on,
                              color: kTerra, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            kGradientButton(
              'Add Listing',
              () async {
                if (_formKey.currentState!.validate()) {
                  final lat = double.tryParse(_latController.text);
                  final lng = double.tryParse(_lngController.text);
                  if (lat == null || lng == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid coordinates',
                            style: GoogleFonts.dmSans()),
                        backgroundColor: kTerra,
                      ),
                    );
                    return;
                  }
                  final listing = ListingModel(
                    name: _nameController.text,
                    category: _category,
                    description: _descController.text,
                    address: _addressController.text,
                    phoneNumber: _phoneController.text,
                    latitude: lat,
                    longitude: lng,
                    createdBy: context.read<AuthProvider>().currentUser!.uid,
                    createdAt: DateTime.now(),
                  );
                  await context.read<ListingsProvider>().createListing(listing);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: Icons.add_location,
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}
