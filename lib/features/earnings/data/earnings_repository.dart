// lib/features/earnings/data/earnings_repository.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/models.dart';

class EarningsRepository {
  final DioClient _client;
  final AppDatabase _db;

  EarningsRepository(this._client, this._db);

  Future<EscrowWallet> getWalletBalance() async {
    try {
      final response = await _client.get(AppConstants.walletBalance);
      return EscrowWallet.fromJson(response);
    } catch (_) {
      return const EscrowWallet(
        availableBalance: 3000.0,
        inEscrowPending: 1500.0,
      );
    }
  }

  Future<List<TripEarningsRecord>> getEarningsHistory() async {
    try {
      final response = await _client.get(AppConstants.earnings);
      final list = (response['earnings_history'] as List<dynamic>?) ?? [];
      final records = list
          .map((e) => TripEarningsRecord.fromJson(
                e is String ? jsonDecode(e) : e as Map<String, dynamic>,
              ))
          .toList();

      for (final r in records) {
        await _db.upsertEarnings({
          'id': r.id,
          'trip_id': r.tripId,
          'total_payout': r.totalPayout,
          'ton_km_splits': jsonEncode(
            r.tonKmContributions.map((c) => {
                  'farmer_name': c.farmerName,
                  'crop_name': c.cropName,
                  'weight_kg': c.weightKg,
                  'distance_km': c.distanceKm,
                  'ton_km': c.tonKm,
                  'payout': c.costShare,
                }).toList(),
          ),
          'status': r.status,
          'created_at': r.createdAt.toIso8601String(),
          'synced': 1,
        });
      }

      return records;
    } catch (_) {
      final localRows = await _db.getEarningsHistory();
      if (localRows.isNotEmpty) {
        return localRows.map((r) {
          final splitsRaw = r['ton_km_splits'] as String? ?? '[]';
          final splits = jsonDecode(splitsRaw) as List<dynamic>;
          return TripEarningsRecord(
            id: r['id'] as String,
            tripId: r['trip_id'] as String,
            totalPayout: (r['total_payout'] as num).toDouble(),
            status: r['status'] as String,
            createdAt: DateTime.parse(r['created_at'] as String),
            tonKmContributions: splits
                .map((e) => FarmerTonKmContribution.fromJson(
                    e as Map<String, dynamic>))
                .toList(),
          );
        }).toList();
      }

      // Default mock fallback
      return [
        TripEarningsRecord(
          id: 'EARN-01',
          tripId: 'TRIP-KS-101',
          totalPayout: 3000.0,
          status: 'SETTLED',
          createdAt: DateTime.now(),
          tonKmContributions: [
            FarmerTonKmContribution(
              farmerName: 'Ramesh Kumar',
              cropName: 'Tomatoes',
              weightKg: 500,
              distanceKm: 14.2,
              tonKm: 7.1,
              costShare: 545.45,
            ),
            FarmerTonKmContribution(
              farmerName: 'Priya Patil',
              cropName: 'Onions',
              weightKg: 750,
              distanceKm: 18.5,
              tonKm: 13.875,
              costShare: 1067.31,
            ),
            FarmerTonKmContribution(
              farmerName: 'Suresh Pawar',
              cropName: 'Grapes',
              weightKg: 750,
              distanceKm: 13.8,
              tonKm: 10.35,
              costShare: 1387.24,
            ),
          ],
        ),
      ];
    }
  }

  Future<bool> requestInstantPayout({
    required double amount,
    required String upiId,
  }) async {
    try {
      final response = await _client.post(
        AppConstants.payoutRequest,
        data: {'amount': amount, 'upi_id': upiId},
      );
      return response['success'] == true;
    } catch (_) {
      return true; // Optimistic for demo
    }
  }
}

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository(
    ref.watch(dioClientProvider),
    ref.watch(databaseProvider),
  );
});
