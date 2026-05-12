import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/listing_model.dart';

class ListingProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  String? _selectedCategory;
  String _searchQuery = '';

  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // ── Real-time streams ──────────────────────────────────────────────────────

  Stream<List<ListingModel>> get listingsStream => _supabase
      .from('listings')
      .stream(primaryKey: ['id'])
      .order('createdAt', ascending: false)
      .map((data) => data
          .where((d) => d['isActive'] == true)
          .map((d) => ListingModel.fromMap(d, d['id']))
          .toList());

  Stream<List<ListingModel>> userListingsStream(String userId) => _supabase
      .from('listings')
      .stream(primaryKey: ['id'])
      .eq('sellerId', userId)
      .order('createdAt', ascending: false)
      .map((data) => data
          .map((d) => ListingModel.fromMap(d, d['id']))
          .toList());

  Stream<ListingModel?> listingStream(String id) => _supabase
      .from('listings')
      .stream(primaryKey: ['id'])
      .eq('id', id)
      .map((data) => data.isNotEmpty
          ? ListingModel.fromMap(data.first, data.first['id'])
          : null);

  // ── Filters ────────────────────────────────────────────────────────────────

  List<ListingModel> applyFilters(List<ListingModel> all) {
    var results = List<ListingModel>.from(all);
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

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Image upload ───────────────────────────────────────────────────────────

  Future<List<String>> _uploadImages(List<File> files, String listingId) async {
    final List<String> urls = [];
    for (int i = 0; i < files.length; i++) {
      try {
        final ext = files[i].path.split('.').last.toLowerCase();
        final path = 'listings/$listingId/img_$i.$ext';
        await _supabase.storage
            .from('listing-images')
            .upload(path, files[i],
                fileOptions: const FileOptions(upsert: true));
        final url = _supabase.storage
            .from('listing-images')
            .getPublicUrl(path);
        urls.add(url);
      } catch (e) {
        debugPrint('Image upload [$i] error: $e');
      }
    }
    return urls;
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  Future<bool> createListing({
    required String title,
    required String description,
    required double price,
    required String category,
    required String location,
    required List<File> imageFiles,
    required String sellerId,
    required String sellerName,
    String sellerPhoto = '',
    bool isForRent = false,
    String? rentPeriod,
  }) async {
    try {
      final id = _uuid.v4();
      final imageUrls = imageFiles.isNotEmpty
          ? await _uploadImages(imageFiles, id)
          : <String>[];

      await _supabase.from('listings').insert({
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'images': imageUrls,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerPhoto': sellerPhoto,
        'location': location,
        'isActive': true,
        'isForRent': isForRent,
        'rentPeriod': rentPeriod,
        'views': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('createListing error: $e');
      return false;
    }
  }

  Future<bool> deleteListing(String listingId) async {
    try {
      await _supabase
          .from('listings')
          .update({'isActive': false}).eq('id', listingId);
      return true;
    } catch (e) {
      debugPrint('deleteListing error: $e');
      return false;
    }
  }

  Future<void> incrementView(String id) async {
    try {
      await _supabase.rpc('increment_view', params: {'listing_id': id});
    } catch (_) {}
  }
}