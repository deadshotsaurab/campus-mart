import 'package:flutter/material.dart';
import '../../../shared/utils/mock_data.dart';
import '../../../features/profile/models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class DemoAuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unauthenticated;
  UserModel? _currentUser;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get errorMessage => null;

  Future<bool> loginWithEmail({required String email, required String password}) async {
    _status = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1200));
    _currentUser = demoUser;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1200));
    _currentUser = UserModel(
      uid: 'demo_new_user',
      name: name,
      email: email,
      phone: phone,
      photoUrl: '',
      college: 'Campus University',
      createdAt: DateTime.now(),
    );
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    _currentUser = demoUser;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
