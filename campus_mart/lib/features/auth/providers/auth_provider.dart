import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/models/user_model.dart';
import '../../../shared/services/otp_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _lastGeneratedOtp; // For manual verification

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _onAuthStateChanged(session?.user);
    });
  }

  Future<void> _onAuthStateChanged(User? supabaseUser) async {
    if (supabaseUser == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
    } else {
      try {
        _currentUser = await _fetchUserProfile(supabaseUser.id);
        _status = AuthStatus.authenticated;
      } catch (_) {
        // Profile fetch failed, might be a new user (OTP/Google)
        // Create the profile if it doesn't exist yet
        final newUser = _userFromSupabase(supabaseUser);
        try {
          await _saveUserProfile(newUser);
          _currentUser = newUser;
        } catch (e) {
          debugPrint('Error creating profile: $e');
          _currentUser = newUser; // Fallback to local model
        }
        _status = AuthStatus.authenticated;
      }
    }
    notifyListeners();
  }

  UserModel _userFromSupabase(User u) => UserModel(
        uid: u.id,
        name: u.userMetadata?['name'] ?? 'User',
        email: u.email ?? '',
        phone: u.phone ?? '',
        photoUrl: u.userMetadata?['avatar_url'] ?? '',
        college: '',
        createdAt: DateTime.now(),
      );

  Future<UserModel> _fetchUserProfile(String uid) async {
    final response =
        await _supabase.from('users').select().eq('uid', uid).maybeSingle();
    if (response != null) {
      return UserModel.fromMap(response, uid);
    }
    throw Exception('User profile not found');
  }

  Future<void> _saveUserProfile(UserModel user) async {
    await _supabase.from('users').upsert(user.toMap());
  }

  Future<UserModel?> fetchPublicProfile(String uid) async {
    try {
      final response =
          await _supabase.from('users').select().eq('uid', uid).maybeSingle();
      if (response != null) {
        return UserModel.fromMap(response, uid);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching public profile: $e');
      return null;
    }
  }

  /// Email OTP Sign In / Sign Up
  Future<bool> signInWithEmailOtp(String email,
      {Map<String, dynamic>? data}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithOtp(email: email, data: data);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Verify Email OTP
  Future<bool> verifyEmailOtp(String email, String token) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth
          .verifyOTP(email: email, token: token, type: OtpType.email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Reset Password OTP
  Future<bool> sendPasswordResetOtp(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Verify Reset Password OTP
  Future<bool> verifyPasswordResetOtp(String email, String token) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth
          .verifyOTP(email: email, token: token, type: OtpType.recovery);
      _status = AuthStatus.loading; // Stay in loading to update password
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Update Password (after verification)
  Future<bool> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      _status = AuthStatus.unauthenticated; // Require re-login
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Email & Password Login
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // Domain restriction for login
    final trimmedEmail = email.toLowerCase().trim();
    if (!trimmedEmail.endsWith('@pondiuni.ac.in') && !trimmedEmail.endsWith('@pondiuni.edu.in')) {
      _errorMessage = 'Only Pondicherry University emails are allowed for login.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Authentication failed. Please try again.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Email & Password Register
  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    String college = 'Campus University',
  }) async {
    // Domain Check
    final trimmedEmail = email.toLowerCase().trim();
    if (!trimmedEmail.endsWith('@pondiuni.ac.in') && !trimmedEmail.endsWith('@pondiuni.edu.in')) {
      _errorMessage = 'Only Pondicherry University emails are allowed for registration.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = res.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.id,
          name: name,
          email: email,
          phone: formattedPhone,
          photoUrl: '',
          college: college,
          createdAt: DateTime.now(),
        );
        await _saveUserProfile(userModel);
        _currentUser = userModel;
      }
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (error) {
      _errorMessage = error.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Google Sign In — uses browser OAuth flow (deep link redirect)
  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
      // Auth state change listener will handle the rest
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Phone Sign In — sends OTP
  Future<bool> signInWithPhone(String phone) async {
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Generate Manual OTP
      final otp = OTPService.generateOTP();
      _lastGeneratedOtp = otp;

      // 2. Send SMS using our custom service
      final success = await OTPService.sendSMS(
        phoneNumber:
            formattedPhone.replaceAll('+', ''), // Fast2SMS doesn't need +
        otpCode: otp,
      );

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Verify Phone OTP
  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Manual Check
      if (otp != _lastGeneratedOtp && otp != '123456') {
        // Allow 123456 as master bypass for demo
        _errorMessage = 'Invalid OTP code';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // 2. Manual Login Workaround (Since we can't create real Supabase SMS sessions)
      // We use email = phone@campus.com and password = phone
      final email = '${phone.replaceAll('+', '')}@campusmart.com';
      final password = 'otp_user_${phone.replaceAll('+', '')}';

      try {
        await _supabase.auth
            .signInWithPassword(email: email, password: password);
      } on AuthException catch (e) {
        if (e.message.contains('Invalid login credentials')) {
          // If user doesn't exist, register them
          await _supabase.auth.signUp(
            email: email,
            password: password,
            data: {'name': 'User ${phone.substring(phone.length - 4)}'},
          );
        } else {
          rethrow;
        }
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Update college field
  Future<void> updateCollege(String college) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(college: college);
    await _saveUserProfile(updated);
    _currentUser = updated;
    notifyListeners();
  }

  /// Update generic profile info
  Future<bool> updateProfile(
      {String? name, String? phone, String? college}) async {
    if (_currentUser == null) return false;
    try {
      debugPrint(
          'Updating profile: name=$name, phone=$phone, college=$college');
      final updated = _currentUser!.copyWith(
        name: name,
        phone: phone,
        college: college,
      );
      await _saveUserProfile(updated);
      _currentUser = updated;
      debugPrint('Profile update success');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Toggle Wishlist
  Future<void> toggleWishlist(String listingId) async {
    if (_currentUser == null) return;

    final updatedWishlist = List<String>.from(_currentUser!.wishlist);
    if (updatedWishlist.contains(listingId)) {
      updatedWishlist.remove(listingId);
    } else {
      updatedWishlist.add(listingId);
    }

    _currentUser = _currentUser!.copyWith(wishlist: updatedWishlist);
    notifyListeners();

    try {
      await _supabase
          .from('users')
          .update({'wishlist': updatedWishlist}).eq('uid', _currentUser!.uid);
    } catch (e) {
      debugPrint('Error updating wishlist: $e');
    }
  }

  /// Update Profile Picture
  Future<bool> updateProfileImage(String filePath) async {
    if (_currentUser == null) return false;

    try {
      final fileExtension = filePath.split('.').last.toLowerCase();
      final fileName =
          '${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final path = 'profiles/$fileName';

      final file = File(filePath);
      // Upload to 'listing-images' bucket (known to work)
      debugPrint('Uploading profile image to listing-images/$path');
      await _supabase.storage.from('listing-images').upload(
            path,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl =
          _supabase.storage.from('listing-images').getPublicUrl(path);
      debugPrint('Upload success. Public URL: $imageUrl');

      final updated = _currentUser!.copyWith(photoUrl: imageUrl);
      await _saveUserProfile(updated);
      _currentUser = updated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
