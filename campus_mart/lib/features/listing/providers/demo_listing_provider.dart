import 'package:flutter/material.dart';
import '../../../shared/utils/mock_data.dart';
import '../models/listing_model.dart';

class DemoListingProvider extends ChangeNotifier {
  String? _selectedCategory;
  String _searchQuery = '';
  final List<ListingModel> _userListings = [];

  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<ListingModel> get listings {
    var results = List<ListingModel>.from(demoListings);
    if (_selectedCategory != null) {
      results = results.where((l) => l.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      results = results
          .where((l) =>
              l.title.toLowerCase().contains(q) ||
              l.description.toLowerCase().contains(q) ||
              l.category.toLowerCase().contains(q))
          .toList();
    }
    return results;
  }

  List<ListingModel> get userListings => _userListings;

  // Simulated stream wrapper
  Stream<List<ListingModel>> get listingsStream =>
      Stream.value(demoListings);

  Stream<List<ListingModel>> get userListingsStream =>
      Stream.value(_userListings);

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> createListing({
    required String title,
    required String description,
    required double price,
    required String category,
    required String location,
    required dynamic imageFiles,
    required String sellerName,
    required String sellerPhoto,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final newListing = ListingModel(
      id: 'listing_demo_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      price: price,
      category: category,
      images: [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600'
      ],
      sellerId: 'demo_user_001',
      sellerName: sellerName,
      sellerPhoto: sellerPhoto,
      location: location,
      createdAt: DateTime.now(),
    );
    _userListings.insert(0, newListing);
    demoListings.insert(0, newListing);
    notifyListeners();
    return true;
  }

  Future<void> deleteListing(String id) async {
    _userListings.removeWhere((l) => l.id == id);
    demoListings.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  Future<void> incrementView(String id) async {}

  Future<void> toggleWishlist(String listingId, String userId) async {
    MockData.toggleWishlist(listingId);
    notifyListeners();
  }
}
