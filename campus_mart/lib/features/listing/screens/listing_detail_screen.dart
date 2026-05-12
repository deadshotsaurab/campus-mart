import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../listing/models/listing_model.dart';
import '../../listing/providers/listing_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../../app/theme.dart';
import 'dart:ui';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _currentImageIndex = 0;
  final PageController _imageController = PageController();

  @override
  void initState() {
    super.initState();
    // Increment view count when detail screen opens
    context.read<ListingProvider>().incrementView(widget.listingId);
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return StreamBuilder<ListingModel?>(
      stream: context.read<ListingProvider>().listingStream(widget.listingId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final listing = snap.data;
        if (listing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Listing not found')),
          );
        }

        final isOwner = auth.currentUser?.uid == listing.sellerId;
        final wishlist = auth.currentUser?.wishlist ?? [];
        final isWishlisted = wishlist.contains(listing.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          extendBodyBehindAppBar: true,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      listing.images.isNotEmpty
                          ? PageView.builder(
                              controller: _imageController,
                              itemCount: listing.images.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentImageIndex = i),
                              itemBuilder: (_, i) => Image.network(
                                listing.images[i],
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, p) =>
                                    p == null ? child : const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Icon(Icons.style,
                                  size: 80, color: Colors.grey),
                            ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                                Colors.transparent,
                                const Color(0xFFF8F9FE),
                              ],
                              stops: const [0.0, 0.2, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ),
                      if (listing.images.length > 1)
                        Positioned(
                          bottom: 40,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              listing.images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 6,
                                width: _currentImageIndex == index ? 24 : 8,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? const Color(0xFFFF4B4B) : Colors.white,
                      ),
                      onPressed: () {
                        context.read<AuthProvider>().toggleWishlist(listing.id);
                      },
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -32, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3E8FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(listing.category,
                                  style: const TextStyle(
                                      color: Color(0xFF2E41C0),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Color(0xFF8A93A6)),
                                const SizedBox(width: 4),
                                Text(
                                  timeago.format(listing.createdAt),
                                  style: const TextStyle(
                                      color: Color(0xFF8A93A6), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(listing.title,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                height: 1.2,
                                color: Color(0xFF14172B))),
                        const SizedBox(height: 12),
                        Text(
                            '${fmt.format(listing.price)}${listing.isForRent ? ' / ${listing.rentPeriod}' : ''}',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                color: AppTheme.primaryColor)),
                        if (listing.isForRent) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                            ),
                            child: const Text(
                              'Available for Rent',
                              style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: const Text(
                              'Available for Sale',
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildInfoChip(Icons.location_on_rounded, listing.location),
                            const SizedBox(width: 12),
                            _buildInfoChip(Icons.remove_red_eye_rounded, '${listing.views} views'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text('Description',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF14172B))),
                        const SizedBox(height: 12),
                        Text(listing.description,
                            style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF596075),
                                height: 1.6)),
                        const SizedBox(height: 32),
                        InkWell(
                          onTap: () => context.push('/profile/${listing.sellerId}'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: listing.sellerPhoto.isNotEmpty
                                      ? NetworkImage(listing.sellerPhoto)
                                      : null,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: listing.sellerPhoto.isEmpty
                                      ? Text(
                                          listing.sellerName.isNotEmpty
                                              ? listing.sellerName[0].toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Seller', style: TextStyle(color: Color(0xFF8A93A6), fontSize: 12, fontWeight: FontWeight.w600)),
                                      Text(listing.sellerName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF14172B))),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primaryColor.withOpacity(0.5)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
                ),
                child: SafeArea(
                  top: false,
                  child: isOwner
                      ? ElevatedButton.icon(
                          onPressed: () async {
                            await context.read<ListingProvider>().deleteListing(listing.id);
                            if (context.mounted) context.pop();
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          label: const Text('Delete Listing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4B4B),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final uid = auth.currentUser?.uid ?? '';
                                  if (uid.isEmpty) {
                                    context.go('/login');
                                    return;
                                  }
                                  final chatId = await context.read<ChatProvider>().getOrCreateChat(
                                    currentUserId: uid,
                                    otherUserId: listing.sellerId,
                                    listingId: listing.id,
                                    listingTitle: listing.title,
                                    listingImage: listing.images.isNotEmpty ? listing.images.first : '',
                                  );
                                  if (context.mounted) {
                                    context.push('/chat/$chatId', extra: {
                                      'listingTitle': listing.title,
                                      'otherUserId': listing.sellerId,
                                    });
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.primaryColor, width: 2),
                                  minimumSize: const Size(0, 54),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final uid = auth.currentUser?.uid ?? '';
                                  if (uid.isEmpty) {
                                    context.go('/login');
                                    return;
                                  }
                                  final chatId = await context.read<ChatProvider>().getOrCreateChat(
                                    currentUserId: uid,
                                    otherUserId: listing.sellerId,
                                    listingId: listing.id,
                                    listingTitle: listing.title,
                                    listingImage: listing.images.isNotEmpty ? listing.images.first : '',
                                  );
                                  if (context.mounted) {
                                    context.push('/chat/$chatId', extra: {
                                      'listingTitle': listing.title,
                                      'otherUserId': listing.sellerId,
                                    });
                                  }
                                },
                                icon: const Icon(Icons.gavel_rounded),
                                label: const Text('MAKE OFFER / BID', style: TextStyle(fontWeight: FontWeight.w900)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 54),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAECEF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8A93A6)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Color(0xFF596075), fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
