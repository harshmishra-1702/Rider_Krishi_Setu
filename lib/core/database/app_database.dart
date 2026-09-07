// lib/core/database/app_database.dart
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/app_constants.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  // In-memory web storage fallback
  final Map<String, List<Map<String, dynamic>>> _webStore = {
    'trips': [],
    'waypoints': [],
    'telemetry_pings': [],
    'offline_queue': [],
    'earnings': [],
  };

  Future<Database?> get database async {
    if (kIsWeb) return null;
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE trips (
        id TEXT PRIMARY KEY,
        vehicle_tier TEXT NOT NULL,
        status TEXT NOT NULL,
        total_trip_cost REAL NOT NULL,
        destination_name TEXT NOT NULL,
        destination_lat REAL NOT NULL,
        destination_lng REAL NOT NULL,
        assigned_at TEXT NOT NULL,
        completed_at TEXT,
        raw_json TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE waypoints (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        stop_order INTEGER NOT NULL,
        farmer_name TEXT NOT NULL,
        contact_phone TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        weight_kg REAL NOT NULL,
        crop_name TEXT NOT NULL,
        batch_qr_code TEXT NOT NULL,
        is_picked_up INTEGER DEFAULT 0,
        picked_up_at TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE telemetry_pings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        speed_kmh REAL,
        heading REAL,
        recorded_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE offline_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        endpoint TEXT NOT NULL,
        method TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE earnings (
        id TEXT PRIMARY KEY,
        trip_id TEXT NOT NULL,
        total_payout REAL NOT NULL,
        ton_km_splits TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migration stubs
  }

  // ── Trip DAOs ──────────────────────────────────────────────────────────────

  Future<void> upsertTrip(Map<String, dynamic> trip) async {
    if (kIsWeb) {
      _webStore['trips']?.removeWhere((t) => t['id'] == trip['id']);
      _webStore['trips']?.add(Map<String, dynamic>.from(trip));
      return;
    }
    final db = (await database)!;
    await db.insert('trips', trip,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getTripById(String id) async {
    if (kIsWeb) {
      final matches =
          _webStore['trips']?.where((t) => t['id'] == id).toList() ?? [];
      return matches.isEmpty ? null : matches.first;
    }
    final db = (await database)!;
    final rows = await db.query('trips', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getActiveTrips() async {
    if (kIsWeb) {
      return _webStore['trips']
              ?.where((t) =>
                  t['status'] != 'DELIVERED' && t['status'] != 'CANCELLED')
              .toList() ??
          [];
    }
    final db = (await database)!;
    return db.query('trips',
        where: 'status NOT IN (?, ?)',
        whereArgs: ['DELIVERED', 'CANCELLED'],
        orderBy: 'assigned_at DESC');
  }

  Future<void> updateTripStatus(String id, String status) async {
    if (kIsWeb) {
      final trip = _webStore['trips']
          ?.firstWhere((t) => t['id'] == id, orElse: () => {});
      if (trip != null && trip.isNotEmpty) {
        trip['status'] = status;
        trip['synced'] = 0;
      }
      return;
    }
    final db = (await database)!;
    await db.update(
      'trips',
      {'status': status, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Waypoint DAOs ──────────────────────────────────────────────────────────

  Future<void> upsertWaypoint(Map<String, dynamic> waypoint) async {
    if (kIsWeb) {
      _webStore['waypoints']?.removeWhere((w) => w['id'] == waypoint['id']);
      _webStore['waypoints']?.add(Map<String, dynamic>.from(waypoint));
      return;
    }
    final db = (await database)!;
    await db.insert('waypoints', waypoint,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getWaypointsByTrip(String tripId) async {
    if (kIsWeb) {
      return _webStore['waypoints']
              ?.where((w) => w['trip_id'] == tripId)
              .toList() ??
          [];
    }
    final db = (await database)!;
    return db.query(
      'waypoints',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'stop_order ASC',
    );
  }

  Future<void> markWaypointPickedUp(String stopId) async {
    if (kIsWeb) {
      final wp = _webStore['waypoints']
          ?.firstWhere((w) => w['id'] == stopId, orElse: () => {});
      if (wp != null && wp.isNotEmpty) {
        wp['is_picked_up'] = 1;
        wp['picked_up_at'] = DateTime.now().toIso8601String();
      }
      return;
    }
    final db = (await database)!;
    await db.update(
      'waypoints',
      {
        'is_picked_up': 1,
        'picked_up_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [stopId],
    );
  }

  // ── Telemetry DAOs ─────────────────────────────────────────────────────────

  Future<void> insertTelemetryPing(Map<String, dynamic> ping) async {
    if (kIsWeb) {
      _webStore['telemetry_pings']?.add(Map<String, dynamic>.from(ping));
      return;
    }
    final db = (await database)!;
    await db.insert('telemetry_pings', ping);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedPings() async {
    if (kIsWeb) {
      return _webStore['telemetry_pings']
              ?.where((p) => p['synced'] == 0)
              .toList() ??
          [];
    }
    final db = (await database)!;
    return db.query('telemetry_pings',
        where: 'synced = 0', orderBy: 'recorded_at ASC', limit: 100);
  }

  Future<void> markPingsSynced(List<int> ids) async {
    if (kIsWeb) return;
    final db = (await database)!;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.rawUpdate(
      'UPDATE telemetry_pings SET synced = 1 WHERE id IN ($placeholders)',
      ids.map((e) => e as Object).toList(),
    );
  }

  // ── Offline Queue DAOs ─────────────────────────────────────────────────────

  Future<void> enqueueOfflineRequest({
    required String endpoint,
    required String method,
    required String payload,
  }) async {
    if (kIsWeb) {
      _webStore['offline_queue']?.add({
        'endpoint': endpoint,
        'method': method,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      });
      return;
    }
    final db = (await database)!;
    await db.insert('offline_queue', {
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    if (kIsWeb) return _webStore['offline_queue'] ?? [];
    final db = (await database)!;
    return db.query('offline_queue', orderBy: 'created_at ASC');
  }

  Future<void> deleteOfflineQueueItem(int id) async {
    if (kIsWeb) return;
    final db = (await database)!;
    await db.delete('offline_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementRetryCount(int id, String error) async {
    if (kIsWeb) return;
    final db = (await database)!;
    await db.rawUpdate(
      'UPDATE offline_queue SET retry_count = retry_count + 1, last_error = ? WHERE id = ?',
      [error, id],
    );
  }

  // ── Earnings DAOs ──────────────────────────────────────────────────────────

  Future<void> upsertEarnings(Map<String, dynamic> earnings) async {
    if (kIsWeb) {
      _webStore['earnings']?.removeWhere((e) => e['id'] == earnings['id']);
      _webStore['earnings']?.add(Map<String, dynamic>.from(earnings));
      return;
    }
    final db = (await database)!;
    await db.insert('earnings', earnings,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEarningsHistory() async {
    if (kIsWeb) return _webStore['earnings'] ?? [];
    final db = (await database)!;
    return db.query('earnings', orderBy: 'created_at DESC');
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    await db?.close();
    _db = null;
  }
}
