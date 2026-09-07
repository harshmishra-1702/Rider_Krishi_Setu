// lib/features/trips/presentation/providers/trip_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/trip_repository.dart';
import '../../domain/models.dart';

// ── Active trip ────────────────────────────────────────────────────────────
final activeTripProvider =
    StateNotifierProvider<ActiveTripNotifier, RideTrip?>(
  (ref) => ActiveTripNotifier(ref.watch(tripRepositoryProvider)),
);

class ActiveTripNotifier extends StateNotifier<RideTrip?> {
  final TripRepository _repo;

  ActiveTripNotifier(this._repo) : super(null);

  Future<void> fetchOffer() async {
    final trip = await _repo.fetchActiveOffer();
    state = trip;
  }

  Future<bool> acceptTrip() async {
    if (state == null) return false;
    final success = await _repo.acceptTrip(state!.tripId);
    if (success) {
      state = state!.copyWith(status: TripStatus.enRoutePickup);
    }
    return success;
  }

  Future<bool> rejectTrip() async {
    if (state == null) return false;
    final success = await _repo.rejectTrip(state!.tripId);
    if (success) state = null;
    return success;
  }

  Future<bool> verifyPickup(String stopId, String qrCode) async {
    if (state == null) return false;
    final success = await _repo.verifyPickup(
      stopId: stopId,
      qrCode: qrCode,
      tripId: state!.tripId,
    );
    if (success) {
      final updatedWaypoints = state!.waypoints.map((wp) {
        if (wp.stopId == stopId) {
          return wp.copyWith(isPickedUp: true, pickedUpAt: DateTime.now());
        }
        return wp;
      }).toList();

      final allPickedUp =
          updatedWaypoints.every((wp) => wp.isPickedUp);
      state = state!.copyWith(
        waypoints: updatedWaypoints,
        status:
            allPickedUp ? TripStatus.inTransit : TripStatus.enRoutePickup,
      );
    }
    return success;
  }

  void completeTrip() {
    state = state?.copyWith(
      status: TripStatus.delivered,
      completedAt: DateTime.now(),
    );
  }

  void setTrip(RideTrip trip) {
    state = trip;
  }

  void markAllPickedUpForDeliveryDemo({bool verifyDeliveries = false}) {
    if (state == null) return;
    final updated = state!.waypoints
        .map((w) => w.copyWith(
              isPickedUp: true,
              isDeliveryVerified: verifyDeliveries,
              pickedUpAt: DateTime.now(),
            ))
        .toList();
    state = state!.copyWith(
      waypoints: updated,
      status: TripStatus.inTransit,
    );
  }

  bool verifyDeliveryBatch(String identifier) {
    if (state == null) return false;
    final cleanId = identifier.trim().toUpperCase().replaceAll('#', '');
    bool matched = false;
    final updated = state!.waypoints.map((w) {
      final wCleanBatch = w.batchId.toUpperCase().replaceAll('#', '');
      final wStopClean = w.stopId.toUpperCase();
      if (wCleanBatch == cleanId ||
          wStopClean == cleanId ||
          w.batchQrCode.toUpperCase().contains(cleanId)) {
        matched = true;
        return w.copyWith(isDeliveryVerified: true);
      }
      return w;
    }).toList();

    if (matched) {
      state = state!.copyWith(waypoints: updated);
    }
    return matched;
  }

  void verifyAllDeliveryBatches() {
    if (state == null) return;
    final updated =
        state!.waypoints.map((w) => w.copyWith(isDeliveryVerified: true)).toList();
    state = state!.copyWith(waypoints: updated);
  }

  void clearTrip() => state = null;
}

// ── Driver online status ───────────────────────────────────────────────────
final isDriverOnlineProvider = StateProvider<bool>((ref) => false);

// ── Location stream ────────────────────────────────────────────────────────
final locationStreamProvider = StreamProvider<Position>((ref) async* {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;
  }
  if (permission == LocationPermission.deniedForever) return;

  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  );
});

// ── Current position (single fetch) ───────────────────────────────────────
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  try {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5),
    );
  } catch (_) {
    return null;
  }
});
