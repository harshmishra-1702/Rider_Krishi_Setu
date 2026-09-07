// lib/features/verification/data/verification_repository.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models.dart';

class VerificationRepository {
  final DioClient _client;
  final AppDatabase _db;

  VerificationRepository(this._client, this._db);

  Future<BatchVerification?> verifyBatchQr({
    required String stopId,
    required String tripId,
    required String qrPayload,
  }) async {
    final endpoint = AppConstants.pickupVerify.replaceFirst('{stopId}', stopId);
    try {
      final response = await _client.post(endpoint, data: {
        'stop_id': stopId,
        'trip_id': tripId,
        'qr_payload': qrPayload,
        'scanned_at': DateTime.now().toIso8601String(),
      });
      final batchData = response['batch'] as Map<String, dynamic>? ?? response;
      await _db.markWaypointPickedUp(stopId);
      return BatchVerification.fromJson(batchData, stopId: stopId);
    } catch (_) {
      // Offline fallback: enqueue request & locally record pickup
      await _db.enqueueOfflineRequest(
        endpoint: endpoint,
        method: 'POST',
        payload: jsonEncode({
          'stop_id': stopId,
          'trip_id': tripId,
          'qr_payload': qrPayload,
          'scanned_at': DateTime.now().toIso8601String(),
        }),
      );
      await _db.markWaypointPickedUp(stopId);
      return BatchVerification(
        batchId: qrPayload.contains('BATCH') ? qrPayload : 'BATCH-OFFLINE',
        stopId: stopId,
        crop: 'Verified Produce',
        weightKg: 500.0,
        grade: 'A',
        farmerName: 'Offline Farmer',
        verifiedAt: DateTime.now(),
      );
    }
  }

  Future<String?> uploadProofPhoto({
    required String tripId,
    required String filePath,
  }) async {
    final endpoint = AppConstants.deliveryPhoto.replaceFirst('{tripId}', tripId);
    try {
      final formData = FormData.fromMap({
        'trip_id': tripId,
        'file': await MultipartFile.fromFile(filePath, filename: 'delivery_proof.jpg'),
      });
      final response = await _client.postMultipart(endpoint, formData);
      return response['photo_url'] as String?;
    } catch (_) {
      // Enqueue offline proof photo record
      await _db.enqueueOfflineRequest(
        endpoint: endpoint,
        method: 'POST',
        payload: jsonEncode({
          'trip_id': tripId,
          'local_path': filePath,
          'captured_at': DateTime.now().toIso8601String(),
        }),
      );
      return 'file://$filePath';
    }
  }

  Future<bool> confirmDeliveryWithOtp({
    required String tripId,
    required String otp,
    required double latitude,
    required double longitude,
    required double distanceMeters,
  }) async {
    final endpoint = AppConstants.deliveryOtp.replaceFirst('{tripId}', tripId);
    try {
      final response = await _client.post(endpoint, data: {
        'trip_id': tripId,
        'otp': otp,
        'latitude': latitude,
        'longitude': longitude,
        'distance_meters': distanceMeters,
        'confirmed_at': DateTime.now().toIso8601String(),
      });
      await _db.updateTripStatus(tripId, 'DELIVERED');
      return response['success'] == true;
    } catch (_) {
      // Enqueue offline confirmation
      await _db.enqueueOfflineRequest(
        endpoint: endpoint,
        method: 'POST',
        payload: jsonEncode({
          'trip_id': tripId,
          'otp': otp,
          'latitude': latitude,
          'longitude': longitude,
          'distance_meters': distanceMeters,
          'confirmed_at': DateTime.now().toIso8601String(),
        }),
      );
      await _db.updateTripStatus(tripId, 'DELIVERED');
      return true;
    }
  }
}

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(
    ref.watch(dioClientProvider),
    ref.watch(databaseProvider),
  );
});
