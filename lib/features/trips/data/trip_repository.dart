// lib/features/trips/data/trip_repository.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models.dart';

class TripRepository {
  final DioClient _client;
  final AppDatabase _db;

  TripRepository(this._client, this._db);

  Future<RideTrip?> fetchActiveOffer() async {
    try {
      final response = await _client.get(AppConstants.rideOffers);
      final trip = RideTrip.fromJson(response);
      await _cacheTrip(trip);
      return trip;
    } catch (_) {
      return await _getCachedActiveTrip();
    }
  }

  Future<bool> acceptTrip(String tripId) async {
    try {
      final endpoint =
          AppConstants.rideAccept.replaceFirst('{id}', tripId);
      await _client.post(endpoint);
      await _db.updateTripStatus(tripId, TripStatus.enRoutePickup.apiString);
      return true;
    } catch (_) {
      await _db.enqueueOfflineRequest(
        endpoint: AppConstants.rideAccept.replaceFirst('{id}', tripId),
        method: 'POST',
        payload: jsonEncode({'trip_id': tripId}),
      );
      return false;
    }
  }

  Future<bool> rejectTrip(String tripId) async {
    try {
      final endpoint =
          AppConstants.rideReject.replaceFirst('{id}', tripId);
      await _client.post(endpoint);
      await _db.updateTripStatus(tripId, TripStatus.cancelled.apiString);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyPickup({
    required String stopId,
    required String qrCode,
    required String tripId,
  }) async {
    try {
      final endpoint =
          AppConstants.pickupVerify.replaceFirst('{stopId}', stopId);
      final response = await _client.post(endpoint, data: {
        'qr_code': qrCode,
        'trip_id': tripId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (response['success'] == true) {
        await _db.markWaypointPickedUp(stopId);
        return true;
      }
      return false;
    } catch (_) {
      await _db.enqueueOfflineRequest(
        endpoint: AppConstants.pickupVerify.replaceFirst('{stopId}', stopId),
        method: 'POST',
        payload: jsonEncode({
          'qr_code': qrCode,
          'trip_id': tripId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      // Optimistic offline update
      await _db.markWaypointPickedUp(stopId);
      return true;
    }
  }

  Future<bool> updateTripStatus(
      String tripId, TripStatus newStatus) async {
    await _db.updateTripStatus(tripId, newStatus.apiString);
    try {
      final endpoint =
          AppConstants.rideAccept.replaceFirst('/accept', '/status').replaceFirst('{id}', tripId);
      await _client.post(endpoint,
          data: {'status': newStatus.apiString});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> sendTelemetryPing({
    required double latitude,
    required double longitude,
    required double? speedKmh,
    String? tripId,
  }) async {
    final ping = {
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'speed_kmh': speedKmh,
      'heading': null,
      'recorded_at': DateTime.now().toIso8601String(),
      'synced': 0,
    };
    await _db.insertTelemetryPing(ping);
    try {
      await _client.post(AppConstants.telemetryPing, data: {
        'trip_id': tripId,
        'latitude': latitude,
        'longitude': longitude,
        'speed_kmh': speedKmh,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Will be synced by background worker
    }
  }

  Future<void> _cacheTrip(RideTrip trip) async {
    final tripMap = trip.toJson();
    await _db.upsertTrip({
      'id': trip.tripId,
      'vehicle_tier': trip.vehicleTier,
      'status': trip.status.apiString,
      'total_trip_cost': trip.totalTripCost,
      'destination_name': trip.destination.name,
      'destination_lat': trip.destination.latitude,
      'destination_lng': trip.destination.longitude,
      'assigned_at': trip.assignedAt.toIso8601String(),
      'completed_at': trip.completedAt?.toIso8601String(),
      'raw_json': jsonEncode(tripMap),
      'synced': 1,
    });
    for (final wp in trip.waypoints) {
      await _db.upsertWaypoint({
        'id': wp.stopId,
        'trip_id': trip.tripId,
        'stop_order': wp.stopOrder,
        'farmer_name': wp.farmerName,
        'contact_phone': wp.contactPhone,
        'latitude': wp.latitude,
        'longitude': wp.longitude,
        'weight_kg': wp.weightKg,
        'crop_name': wp.cropName,
        'batch_qr_code': wp.batchQrCode,
        'is_picked_up': wp.isPickedUp ? 1 : 0,
        'picked_up_at': wp.pickedUpAt?.toIso8601String(),
      });
    }
  }

  Future<RideTrip?> _getCachedActiveTrip() async {
    final rows = await _db.getActiveTrips();
    if (rows.isEmpty) return null;
    final row = rows.first;
    final rawJson = row['raw_json'] as String;
    return RideTrip.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
  }
}

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return TripRepository(
    ref.watch(dioClientProvider),
    ref.watch(databaseProvider),
  );
});
