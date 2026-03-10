import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../models/listing_model.dart';
import '../widgets/ui_helpers.dart';
import 'add_listing_screen.dart';
import 'listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      body: StreamBuilder<List<ListingModel>>(
        stream: context.read<ListingsProvider>().getUserListingsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: List.generate(4, (_) => kShimmerCard()),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: kTerra, size: 56),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', style: GoogleFonts.dmSans(color: kMuted)),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_location_alt, color: kMuted, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'No listings yet',
                      style: GoogleFonts.dmSans(fontSize: 15, color: kMuted),
                    ),
                    const SizedBox(height: 24),
                    kGradientButton(
                      'Add Your First Place',
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen())),
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),
            );
          }
          final listings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: listings.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    '${listings.length} ${listings.length == 1 ? 'listing' : 'listings'}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                  ),
                );
              }
              final listing = listings[index - 1];
              return Dismissible(
                key: Key(listing.id!),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: kSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text('Delete Listing', style: GoogleFonts.playfairDisplay(color: kCream)),
                      content: Text('Are you sure?', style: GoogleFonts.dmSans(color: kMuted)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel', style: GoogleFonts.dmSans(color: kCream)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) async {
                  await context.read<ListingsProvider>().deleteListing(listing.id!);
                },
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: kCategoryBadge(listing.category),
                    title: Text(listing.name, style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kCream,
                    )),
                    subtitle: Text(
                      '${listing.category} • ${listing.address}',
                      style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: kGold),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing, canEdit: true)),
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing, canEdit: true)),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Listing'),
      ),
    );
  }
}
