import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../listing/models/listing_model.dart';
import '../../listing/providers/listing_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': Icons.apps, 'value': null},
    {'label': 'Books', 'icon': Icons.menu_book, 'value': 'Books'},
    {'label': 'Electronics', 'icon': Icons.devices, 'value': 'Electronics'},
    {'label': 'Furniture', 'icon': Icons.chair, 'value': 'Furniture'},
    {'label': 'Clothing', 'icon': Icons.checkroom, 'value': 'Clothing'},
    {'label': 'Sports', 'icon': Icons.sports, 'value': 'Sports'},
    {'label': 'Notes', 'icon': Icons.description, 'value': 'Notes'},
    {'label': 'Other', 'icon': Icons.category, 'value': 'Other'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = context.watch<ListingProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCategory = listingProvider.selectedCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F5),
      body: StreamBuilder<List<ListingModel>>(
        stream: listingProvider.listingsStream,
        builder: (context, snap) {
          final allListings = snap.data ?? [];
          final listings = listingProvider.applyFilters(allListings);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                title: Text(
                  'Campus Mart',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
                centerTitle: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildSearchBar(listingProvider),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final isSelected = selectedCategory == cat['value'];
                      return GestureDetector(
                        onTap: () => listingProvider.setCategory(cat['value']),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected ? colorScheme.primary : const Color(0xFFEBEEEF),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat['icon'] as IconData,
                                size: 18,
                                color: isSelected ? colorScheme.primary : const Color(0xFF406367),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cat['label'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                  color: isSelected ? colorScheme.primary : const Color(0xFF002F34),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              listings.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Color(0xFF406367)),
                            SizedBox(height: 16),
                            Text('No listings found', style: TextStyle(fontSize: 18, color: Color(0xFF406367))),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _ListingCard(listing: listings[i]),
                          childCount: listings.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ListingProvider provider) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEBEEEF)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setSearch,
        style: const TextStyle(fontSize: 16, color: Color(0xFF002F34), fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          hintText: 'Search for cars, phones, etc.',
          hintStyle: TextStyle(color: Color(0xFF406367), fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search, color: Color(0xFF002F34)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: false,
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFEBEEEF)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  listing.images.isNotEmpty
                      ? Image.network(
                          listing.images.first,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: const Color(0xFFEBEEEF),
                              highlightColor: Colors.white,
                              child: Container(color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFF2F4F5),
                          child: const Icon(Icons.image_outlined, size: 40, color: Color(0xFF406367)),
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8F064),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('FEATURED', style: TextStyle(color: Color(0xFF002F34), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: listing.isForRent ? const Color(0xFFFFE082) : const Color(0xFFB3E5FC),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            listing.isForRent ? 'FOR RENT' : 'FOR SALE',
                            style: const TextStyle(color: Color(0xFF002F34), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fmt.format(listing.price),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
                        ),
                        if (listing.isForRent && listing.rentPeriod != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 2, bottom: 2),
                            child: Text(
                              ' / ${listing.rentPeriod}',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF406367)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF406367), fontWeight: FontWeight.w400),
                    ),
                    const Spacer(),
                    const Spacer(),
                    Text(
                      timeago.format(listing.createdAt),
                      style: const TextStyle(fontSize: 10, color: Color(0xFF406367), fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
