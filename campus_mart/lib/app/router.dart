import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/listing/screens/listing_detail_screen.dart';
import '../../features/listing/screens/create_listing_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_room_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/public_profile_screen.dart';
import '../../features/profile/screens/wishlist_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/purchases_screen.dart';
import '../../shared/widgets/main_shell.dart';

GoRouter buildRouter(BuildContext context) {
  final authProvider = context.read<AuthProvider>();

  return GoRouter(
    initialLocation: '/splash',
    // 🔑 refreshListenable makes GoRouter re-evaluate redirect whenever
    // AuthProvider notifies — enabling seamless auto-login & auto-logout
    refreshListenable: authProvider,
    redirect: (ctx, state) {
      final isAuth = authProvider.isAuthenticated;
      final isInitial = authProvider.status == AuthStatus.initial;
      final location = state.matchedLocation;

      // Always allow splash while initializing
      if (location == '/splash') return null;

      // Still loading auth state — stay on splash
      if (isInitial) return '/splash';

      // Handle Supabase OAuth deep link
      if (location.startsWith('/login-callback')) {
         return '/splash';
      }

      // Not logged in → redirect to login (unless already on auth screens)
      if (!isAuth &&
          !location.startsWith('/login') &&
          !location.startsWith('/register') &&
          !location.startsWith('/verify-otp') &&
          !location.startsWith('/onboarding')) {
        return '/login';
      }

      // Logged in → skip auth screens
      if (isAuth &&
          (location.startsWith('/login') ||
              location.startsWith('/register') ||
              location.startsWith('/onboarding'))) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/verify-otp',
        builder: (ctx, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OTPVerificationScreen(
            phoneNumber: extra['phone'] as String?,
            email: extra['email'] as String?,
            isPasswordReset: extra['isPasswordReset'] as bool? ?? false,
            registrationData: extra['registrationData'] as Map<String, String>?,
          );
        },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (ctx, state) {
          final email = state.extra as String;
          return ResetPasswordScreen(email: email);
        },
      ),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/chats', builder: (_, __) => const ChatListScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
          GoRoute(path: '/purchases', builder: (_, __) => const PurchasesScreen()),
        ],
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (ctx, state) {
          final id = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '/create-listing',
        builder: (_, __) => const CreateListingScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (ctx, state) {
          final userId = state.pathParameters['userId']!;
          return PublicProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (ctx, state) {
          final chatId = state.pathParameters['chatId']!;
          final extra = state.extra as Map<String, String>?;
          return ChatRoomScreen(
            chatId: chatId,
            listingTitle: extra?['listingTitle'] ?? '',
            otherUserId: extra?['otherUserId'] ?? '',
          );
        },
      ),
    ],
    errorBuilder: (ctx, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
