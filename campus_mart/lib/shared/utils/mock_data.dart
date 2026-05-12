import '../../../features/listing/models/listing_model.dart';
import '../../../features/profile/models/user_model.dart';

// ─────────────────────────────────────────────
// Mock data for demo mode (no Firebase needed)
// ─────────────────────────────────────────────

final UserModel demoUser = UserModel(
  uid: 'demo_user_001',
  name: 'Adarsh Kumar',
  email: 'adarsh@campus.edu',
  phone: '9876543210',
  photoUrl: '',
  college: 'Campus University',
  createdAt: DateTime.now().subtract(const Duration(days: 30)),
  wishlist: ['listing_003'],
);

final List<ListingModel> demoListings = [
  ListingModel(
    id: 'listing_001',
    title: 'Engineering Mathematics Textbook',
    description:
        'B.S. Grewal Engineering Mathematics, 44th edition. Excellent condition. Used for only one semester. No marks or highlights.',
    price: 350,
    category: 'Books',
    images: [
      'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600'
    ],
    sellerId: 'user_002',
    sellerName: 'Priya Sharma',
    sellerPhoto: '',
    location: 'Block A, Hostel',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    views: 42,
  ),
  ListingModel(
    id: 'listing_002',
    title: 'Laptop Stand + Cooling Pad',
    description:
        'Aluminium laptop stand (adjustable) + USB cooling pad with 2 fans. Works perfectly. Selling because I upgraded my setup.',
    price: 899,
    category: 'Electronics',
    images: [
      'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600'
    ],
    sellerId: 'user_003',
    sellerName: 'Rohan Verma',
    sellerPhoto: '',
    location: 'Library Block',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    views: 78,
  ),
  ListingModel(
    id: 'listing_003',
    title: 'Study Table with Chair',
    description:
        'Wooden study table (4ft x 2ft) with cushioned chair. Minor scratches on table top. Moving out of hostel, must sell.',
    price: 1800,
    category: 'Furniture',
    images: [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600'
    ],
    sellerId: 'user_004',
    sellerName: 'Sneha Patel',
    sellerPhoto: '',
    location: 'Girls Hostel, Room 204',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    views: 120,
  ),
  ListingModel(
    id: 'listing_004',
    title: 'JBL Bluetooth Speaker',
    description:
        'JBL Flip 5 Bluetooth Speaker in blue. Battery life is still great (8+ hours). Waterproof. Comes with original cable.',
    price: 2200,
    category: 'Electronics',
    images: [
      'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600'
    ],
    sellerId: 'user_005',
    sellerName: 'Arjun Singh',
    sellerPhoto: '',
    location: 'Boys Hostel Block C',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    views: 210,
  ),
  ListingModel(
    id: 'listing_005',
    title: 'Data Structures Notes (Handwritten)',
    description:
        'Complete handwritten notes for Data Structures & Algorithms. Includes arrays, linked lists, trees, graphs, and sorting algorithms. Very neat writing.',
    price: 150,
    category: 'Notes',
    images: [
      'https://images.unsplash.com/photo-1509966756634-9c23dd6e6815?w=600'
    ],
    sellerId: 'user_006',
    sellerName: 'Kavya Menon',
    sellerPhoto: '',
    location: 'Dept. of CSE',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    views: 55,
  ),
  ListingModel(
    id: 'listing_006',
    title: 'Cricket Kit (Complete)',
    description:
        'Full cricket kit: bat (English willow), pads, gloves, helmet, and bag. Used for 1 season. Brand: SG.',
    price: 3500,
    category: 'Sports',
    images: [
      'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=600'
    ],
    sellerId: 'user_007',
    sellerName: 'Dhruv Nair',
    sellerPhoto: '',
    location: 'Sports Block',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    views: 88,
  ),
  ListingModel(
    id: 'listing_007',
    title: 'Nike Running Shoes (Size 42)',
    description:
        'Nike Revolution 6 running shoes. Size EU 42 / UK 8. Worn only twice. Selling because of wrong size. Original box included.',
    price: 1200,
    category: 'Clothing',
    images: [
      'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600'
    ],
    sellerId: 'user_008',
    sellerName: 'Meera Iyer',
    sellerPhoto: '',
    location: 'Hostel Block B',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    views: 145,
  ),
  ListingModel(
    id: 'listing_008',
    title: 'Casio Scientific Calculator fx-991ES',
    description:
        'Casio fx-991ES PLUS scientific calculator. Works perfectly. Essential for engineering exams. Comes with slide cover.',
    price: 400,
    category: 'Electronics',
    images: [
      'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=600'
    ],
    sellerId: 'user_009',
    sellerName: 'Vikram Rao',
    sellerPhoto: '',
    location: 'Main Academic Block',
    createdAt: DateTime.now().subtract(const Duration(days: 6)),
    views: 97,
  ),
];

class MockData {
  static List<String> wishlist = ['listing_003'];

  static void toggleWishlist(String id) {
    if (wishlist.contains(id)) {
      wishlist.remove(id);
    } else {
      wishlist.add(id);
    }
  }
}
