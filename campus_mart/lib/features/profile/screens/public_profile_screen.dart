import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/user_model.dart';
import '../../listing/providers/listing_provider.dart';
import '../../listing/models/listing_model.dart';
import '../../../app/theme.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final listingProvider = context.read<ListingProvider>();

    return FutureBuilder<UserModel?>(
      future: auth.fetchPublicProfile(userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        final publicUser = userSnapshot.data;
        final isOwnProfile = userId == auth.currentUser?.uid;
        
        return StreamBuilder<List<ListingModel>>(
          stream: listingProvider.userListingsStream(userId),
          builder: (context, listingSnapshot) {
            final listings = listingSnapshot.data ?? [];
            final userName = publicUser?.name ?? (listings.isNotEmpty ? listings.first.sellerName : 'Campus User');
            final userPhoto = publicUser?.photoUrl ?? '';
            final userCollege = publicUser?.college ?? 'Verified Campus Member';

            return Scaffold(
              backgroundColor: const Color(0xFFF2F4F5),
              appBar: AppBar(
                title: Text(isOwnProfile ? 'My Public Profile' : 'Member Profile'),
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            backgroundImage: userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
                            child: userPhoto.isEmpty 
                              ? Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                                )
                              : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.school_outlined, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                userCollege,
                                style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: _StatItem(label: 'Total Ads', value: listings.length.toString())),
                              Expanded(child: _StatItem(label: 'Member Since', value: publicUser != null ? DateFormat('yyyy').format(publicUser.createdAt) : '2024')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Seller\'s Active Items',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(height: 16),
                          if (listingSnapshot.connectionState == ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator())
                          else if (listings.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Text(
                                  'No active listings from this user.',
                                  style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                                ),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemCount: listings.length,
                              itemBuilder: (context, index) {
                                final listing = listings[index];
                                final hasImage = listing.images.isNotEmpty;

                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  child: InkWell(
                                    onTap: () => context.push('/listing/${listing.id}'),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: hasImage 
                                              ? Image.network(
                                                  listing.images.first,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (ctx, _, __) => Container(
                                                    color: Colors.grey[100],
                                                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                                  ),
                                                )
                                              : Container(
                                                  color: Colors.grey[100],
                                                  child: const Icon(Icons.image_outlined, color: Colors.grey),
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                listing.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '₹${listing.price}',
                                                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary.withOpacity(0.6), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
