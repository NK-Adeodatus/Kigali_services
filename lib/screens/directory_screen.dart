import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/listings_provider.dart';
import '../models/listing_model.dart';
import '../widgets/ui_helpers.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  static const categories = [
    'All',
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Directory')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => context.read<ListingsProvider>().setSearchQuery(v),
            ),
          ),
          Consumer<ListingsProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = provider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: cat == 'All'
                            ? null
                            : Icon(kCategoryIcon(cat), size: 14,
                                color: isSelected ? Colors.white : kCategoryColor(cat)),
                        label: Text(cat, style: GoogleFonts.dmSans(
                          color: isSelected ? Colors.white : kCream,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 12,
                        )),
                        selected: isSelected,
                        onSelected: (_) => provider.setCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          Expanded(
            child: Consumer<ListingsProvider>(
              builder: (context, provider, _) {
                return StreamBuilder<List<ListingModel>>(
                  stream: provider.getFilteredListingsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: List.generate(6, (_) => kShimmerCard()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: kTerra, size: 56),
                            const SizedBox(height: 16),
                            Text('Error: ${snapshot.error}',
                                style: GoogleFonts.dmSans(color: kMuted)),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, color: kMuted, size: 64),
                            const SizedBox(height: 16),
                            Text('No listings found',
                                style: GoogleFonts.dmSans(fontSize: 15, color: kMuted)),
                            const SizedBox(height: 8),
                            Text('Try adjusting your search or filter',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: kMuted.withValues(alpha: 0.7))),
                          ],
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
                              '${listings.length} ${listings.length == 1 ? 'place' : 'places'} found',
                              style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                            ),
                          );
                        }
                        final listing = listings[index - 1];
                        return _ListingCard(listing: listing)
                            .animate(delay: ((index - 1) * 50).ms)
                            .fadeIn(duration: 350.ms)
                            .slideX(begin: 0.05);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingDetailScreen(listing: listing)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kCategoryBadge(listing.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kCream),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kCategoryColor(listing.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            listing.category,
                            style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: kCategoryColor(listing.category),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: kTerra, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: kGreenLight, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          listing.phoneNumber,
                          style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: kTerra, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
