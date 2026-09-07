// lib/features/auth/data/auth_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models.dart';

class AuthRepository {
  final DioClient _client;
  final FlutterSecureStorage _storage;

  AuthRepository(this._client, this._storage);

  Future<void> sendOtp(String phone) async {
    await _client.post(
      AppConstants.authSendOtp,
      data: {'phone': phone},
    );
  }

  Future<({String token, String driverId, bool isNewUser})> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _client.post(
      AppConstants.authVerifyOtp,
      data: {'phone': phone, 'otp': otp},
    );
    final token = response['token'] as String;
    final driverId = response['driver_id'] as String;
    final isNewUser = response['is_new_user'] as bool? ?? false;

    await _storage.write(key: AppConstants.keyAuthToken, value: token);
    await _storage.write(key: AppConstants.keyDriverId, value: driverId);

    return (token: token, driverId: driverId, isNewUser: isNewUser);
  }

  Future<Driver?> getDriverProfile() async {
    try {
      final response = await _client.get(AppConstants.authProfile);
      return Driver.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<Driver> updateDriverProfile({
    required String name,
    required String licenseNumber,
    required VehicleTier vehicleTier,
    required String vehicleNumber,
    required String vehicleModel,
    String? upiId,
  }) async {
    final response = await _client.post(
      AppConstants.authProfile,
      data: {
        'name': name,
        'license_number': licenseNumber,
        'vehicle_tier': vehicleTier.name.toUpperCase(),
        'vehicle_number': vehicleNumber,
        'vehicle_model': vehicleModel,
        'upi_id': upiId,
      },
    );
    return Driver.fromJson(response);
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: AppConstants.keyAuthToken);
    return token != null;
  }

  Future<void> signOut() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyDriverId);
  }

  Future<String?> getSavedLanguage() async {
    return _storage.read(key: AppConstants.keySelectedLanguage);
  }

  Future<void> saveLanguage(String languageCode) async {
    await _storage.write(
        key: AppConstants.keySelectedLanguage, value: languageCode);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(dioClientProvider),
    ref.watch(secureStorageProvider),
  );
});
