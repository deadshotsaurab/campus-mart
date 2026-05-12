

class ListingModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String sellerPhoto;
  final String location;
  final DateTime createdAt;
  final bool isActive;
  final bool isForRent;
  final String? rentPeriod;
  final int views;

  ListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.images = const [],
    required this.sellerId,
    required this.sellerName,
    this.sellerPhoto = '',
    required this.location,
    required this.createdAt,
    this.isActive = true,
    this.isForRent = false,
    this.rentPeriod,
    this.views = 0,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map, String id) {
    return ListingModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? 'Other',
      images: List<String>.from(map['images'] ?? []),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerPhoto: map['sellerPhoto'] ?? '',
      location: map['location'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
      isActive: map['isActive'] ?? true,
      isForRent: map['isForRent'] ?? false,
      rentPeriod: map['rentPeriod'],
      views: map['views'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhoto': sellerPhoto,
      'location': location,
      'isActive': isActive,
      'isForRent': isForRent,
      'rentPeriod': rentPeriod,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
    };
  }

  ListingModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    List<String>? images,
    String? sellerId,
    String? sellerName,
    String? sellerPhoto,
    String? location,
    DateTime? createdAt,
    bool? isActive,
    bool? isForRent,
    String? rentPeriod,
    int? views,
  }) {
    return ListingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhoto: sellerPhoto ?? this.sellerPhoto,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isForRent: isForRent ?? this.isForRent,
      rentPeriod: rentPeriod ?? this.rentPeriod,
      views: views ?? this.views,
    );
  }
}