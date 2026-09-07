// lib/core/config/app_constants.dart
class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.krishisetu.dev/api/v1';
  static const String wsUrl = 'wss://api.krishisetu.dev/ws/v1';

  // Mock flag — set false for production
  static const bool useMockApi = true;

  // Endpoints
  static const String authSendOtp = '/auth/driver/send-otp';
  static const String authVerifyOtp = '/auth/driver/verify-otp';
  static const String authProfile = '/auth/driver/profile';
  static const String rideOffers = '/logistics/rides/offers';
  static const String rideAccept = '/logistics/rides/{id}/accept';
  static const String rideReject = '/logistics/rides/{id}/reject';
  static const String rideWaypoints = '/logistics/rides/{id}/waypoints';
  static const String pickupVerify = '/logistics/pickups/{stopId}/verify';
  static const String deliveryPhoto = '/logistics/deliveries/{tripId}/photo';
  static const String deliveryOtp = '/logistics/deliveries/{tripId}/confirm';
  static const String telemetryPing = '/logistics/telemetry/ping';
  static const String earnings = '/escrow/driver/earnings';
  static const String walletBalance = '/escrow/driver/wallet';
  static const String payoutRequest = '/escrow/driver/payout';

  // Local DB
  static const String dbName = 'krishisetu_rider.db';
  static const int dbVersion = 1;

  // Geofence
  static const double geofenceRadiusMeters = 100.0;

  // Trip offer timeout
  static const int tripOfferTimeoutSeconds = 30;

  // Secure storage keys
  static const String keyAuthToken = 'auth_token';
  static const String keyDriverId = 'driver_id';
  static const String keySelectedLanguage = 'selected_language';

  // Supported locales
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'mr', 'name': 'Marathi', 'native': 'मराठी'},
    {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
    {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
  ];
}
