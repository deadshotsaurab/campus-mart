import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/providers/auth_provider.dart';
import '../../listing/providers/listing_provider.dart';
import '../../listing/models/listing_model.dart';
import '../../../app/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
    );

    if (image == null) return;

    if (!context.mounted) return;
    setState(() => _isUploading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfileImage(image.path);

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Color(0xFF10B981)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Upload failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Color(0xFFEBEEEF)),
              const SizedBox(height: 24),
              Text(
                'Please login to continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final listingProvider = context.read<ListingProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryColor,
            surfaceTintColor: AppTheme.primaryColor,
            leading: context.canPop() ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()) : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF002F34), Color(0xFF004047)],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: const Color(0xFFF2F4F5),
                                backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                                child: user.photoUrl.isEmpty
                                    ? Text(
                                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isUploading ? null : () => _pickAndUploadImage(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC8F064),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                  child: _isUploading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF002F34)))
                                      : const Icon(Icons.camera_alt, size: 20, color: Color(0xFF002F34)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFEBEEEF)),
                    ),
                    child: Row(
                      children: [
                        StreamBuilder<List<ListingModel>>(
                          stream: listingProvider.userListingsStream(user.uid),
                          builder: (context, snap) {
                            final count = snap.data?.length ?? 0;
                            return _StatItem(count: count, label: 'Listings');
                          },
                        ),
                        Container(width: 1, height: 40, color: const Color(0xFFEBEEEF)),
                        GestureDetector(
                          onTap: () => context.push('/wishlist'),
                          child: _StatItem(
                            count: user.wishlist.length,
                            label: 'Saved',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFEBEEEF)),
                    ),
                    child: Column(
                      children: [
                        if (user.phone.isNotEmpty)
                          _MenuTile(
                            icon: Icons.phone_android_outlined,
                            label: user.phone,
                            showArrow: false,
                          ),
                        _MenuTile(
                          icon: Icons.email_outlined,
                          label: user.email,
                          showArrow: false,
                        ),
                        if (user.college.isNotEmpty)
                          _MenuTile(
                            icon: Icons.school_outlined,
                            label: user.college,
                            showArrow: false,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFEBEEEF)),
                    ),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.favorite_outline,
                          label: 'My Wishlist',
                          onTap: () => context.push('/wishlist'),
                        ),
                        _MenuTile(
                          icon: Icons.shopping_bag_outlined,
                          label: 'My Purchases',
                          onTap: () => context.push('/purchases'),
                        ),
                        _MenuTile(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () => context.push('/settings'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Listings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
                      ),
                      TextButton(
                        onPressed: () => context.push('/create-listing'),
                        child: const Text('Add New', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF3A77FF))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<List<ListingModel>>(
                    stream: listingProvider.userListingsStream(user.uid),
                    builder: (context, listSnap) {
                      final listings = listSnap.data ?? [];
                      return listings.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(40),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFEBEEEF)),
                              ),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.sell_outlined, size: 48, color: Color(0xFFEBEEEF)),
                                    SizedBox(height: 16),
                                    Text(
                                      "You haven't posted anything yet",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFF406367), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: listings.length,
                              itemBuilder: (_, i) => _MyListingTile(listing: listings[i]),
                            );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF406367), letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

class _MyListingTile extends StatelessWidget {
  final ListingModel listing;

  const _MyListingTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return GestureDetector(
      onTap: () => context.push('/listing/${listing.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFEBEEEF)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: listing.images.isNotEmpty
                  ? Image.network(
                      listing.images.first,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _noImage(),
                    )
                  : _noImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF002F34)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(listing.price),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF002F34)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEEEF),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF406367)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noImage() {
    return Container(
      width: 70,
      height: 70,
      color: const Color(0xFFF2F4F5),
      child: const Icon(Icons.image_outlined, color: Color(0xFF406367)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showArrow;

  const _MenuTile({required this.icon, required this.label, this.onTap, this.showArrow = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF002F34), size: 22),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF002F34)),
      ),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF002F34)) : null,
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

