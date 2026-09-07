// lib/core/services/sync_service.dart
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../providers/core_providers.dart';

class SyncService {
  final AppDatabase _db;
  final DioClient _client;
  bool _isSyncing = false;

  SyncService(this._db, this._client);

  void startListening() {
    Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet);

      if (isConnected) {
        flushQueue();
      }
    });
  }

  Future<void> flushQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // 1. Sync telemetry pings
      final pings = await _db.getUnsyncedPings();
      if (pings.isNotEmpty) {
        final pingIds = <int>[];
        for (final p in pings) {
          try {
            await _client.post(
              '/logistics/telemetry/ping',
              data: {
                'trip_id': p['trip_id'],
                'latitude': p['latitude'],
                'longitude': p['longitude'],
                'speed_kmh': p['speed_kmh'],
                'timestamp': p['recorded_at'],
              },
            );
            pingIds.add(p['id'] as int);
          } catch (_) {
            break;
          }
        }
        if (pingIds.isNotEmpty) {
          await _db.markPingsSynced(pingIds);
        }
      }

      // 2. Sync queued offline requests
      final queueItems = await _db.getOfflineQueue();
      for (final item in queueItems) {
        final id = item['id'] as int;
        final endpoint = item['endpoint'] as String;
        final method = item['method'] as String;
        final payloadRaw = item['payload'] as String;

        try {
          final payload = jsonDecode(payloadRaw) as Map<String, dynamic>;
          if (method == 'POST') {
            await _client.post(endpoint, data: payload);
          } else if (method == 'PUT') {
            await _client.put(endpoint, data: payload);
          }
          await _db.deleteOfflineQueueItem(id);
        } catch (e) {
          await _db.incrementRetryCount(id, e.toString());
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.watch(databaseProvider),
    ref.watch(dioClientProvider),
  );
  service.startListening();
  return service;
});
