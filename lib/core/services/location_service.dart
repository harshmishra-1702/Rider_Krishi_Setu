// lib/core/services/location_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

enum LocationCheckResult {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  granted,
}

class LocationService {
  Future<bool> isServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (_) {
      return LocationPermission.denied;
    }
  }

  Future<LocationCheckResult> checkAndRequestPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationCheckResult.serviceDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationCheckResult.permissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationCheckResult.permissionDeniedForever;
      }

      return LocationCheckResult.granted;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return LocationCheckResult.permissionDenied;
    }
  }

  Future<Position?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final result = await checkAndRequestPermission();
      if (result != LocationCheckResult.granted) {
        if (result != LocationCheckResult.serviceDisabled) {
          return await Geolocator.getLastKnownPosition();
        }
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );
    } catch (e) {
      debugPrint('getCurrentPosition error: $e');
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
