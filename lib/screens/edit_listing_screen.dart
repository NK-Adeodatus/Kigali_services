import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/listings_provider.dart';
import '../models/listing_model.dart';
import '../widgets/ui_helpers.dart';

class EditListingScreen extends StatefulWidget {
  final ListingModel listing;
  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late String _category;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.listing.name);
    _descController = TextEditingController(text: widget.listing.description);
    _addressController = TextEditingController(text: widget.listing.address);
    _phoneController = TextEditingController(text: widget.listing.phoneNumber);
    _latController = TextEditingController(text: widget.listing.latitude.toString());
    _lngController = TextEditingController(text: widget.listing.longitude.toString());
    _category = widget.listing.category;
  }

  @override
  void dispose() {
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
      appBar: AppBar(title: const Text('Edit Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              dropdownColor: kSurface2,
              style: GoogleFonts.dmSans(color: kCream),
              items: ['Hospital', 'Police Station', 'Library', 'Restaurant', 'Café', 'Park', 'Tourist Attraction']
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(kCategoryIcon(c), size: 16, color: kCategoryColor(c)),
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
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (v) {
                      if (v!.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            kGradientButton(
              'Update Listing',
              () async {
                if (_formKey.currentState!.validate()) {
                  await context.read<ListingsProvider>().updateListing(widget.listing.id!, {
                    'name': _nameController.text,
                    'category': _category,
                    'description': _descController.text,
                    'address': _addressController.text,
                    'phoneNumber': _phoneController.text,
                    'latitude': double.parse(_latController.text),
                    'longitude': double.parse(_lngController.text),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: Icons.save,
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}
