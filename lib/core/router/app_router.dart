// lib/core/router/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/language_select_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/vehicle_profile_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/support/presentation/screens/complaint_screen.dart';
import '../../features/trips/presentation/screens/home_screen.dart';
import '../../features/trips/presentation/screens/route_screen.dart';
import '../../features/trips/presentation/screens/trip_history_screen.dart';
import '../../features/verification/presentation/screens/otp_delivery_screen.dart';
import '../../features/verification/presentation/screens/photo_capture_screen.dart';
import '../../features/verification/presentation/screens/qr_scanner_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LanguageSelectScreen(fromSettings: from == 'settings');
        },
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/vehicle-profile',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'];
          return VehicleProfileScreen(initialPhone: phone);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/route',
        builder: (context, state) => const RouteScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) {
          final stopId = state.uri.queryParameters['stopId'] ?? 'STOP-001';
          final cropName = state.uri.queryParameters['crop'];
          final weightKg = state.uri.queryParameters['weight'];
          var batchId = state.uri.queryParameters['batchId'];
          if (batchId == null || batchId.isEmpty) {
            // Check if it was placed as URI fragment e.g. #4092
            if (state.uri.fragment.isNotEmpty) {
              batchId = '#${state.uri.fragment}';
            } else {
              batchId = '#4092';
            }
          }
          if (!batchId.startsWith('#')) {
            batchId = '#$batchId';
          }
          return QrScannerScreen(
            stopId: stopId,
            cropName: cropName,
            weightKg: weightKg,
            batchId: batchId,
          );
        },
      ),
      GoRoute(
        path: '/photo-capture',
        builder: (context, state) => const PhotoCaptureScreen(),
      ),
      GoRoute(
        path: '/otp-delivery',
        builder: (context, state) => const OtpDeliveryScreen(),
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const TripHistoryScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/complaint',
        builder: (context, state) => const ComplaintScreen(),
      ),
    ],
  );
});
