// lib/features/earnings/domain/models.dart
import 'dart:convert';

class FarmerTonKmContribution {
  final String farmerName;
  final String cropName;
  final String batchId;
  final double weightKg;
  final double distanceKm;
  final double tonKm;
  final double costShare;

  const FarmerTonKmContribution({
    required this.farmerName,
    required this.cropName,
    this.batchId = '#4092',
    required this.weightKg,
    required this.distanceKm,
    required this.tonKm,
    required this.costShare,
  });

  factory FarmerTonKmContribution.fromJson(Map<String, dynamic> json) =>
      FarmerTonKmContribution(
        farmerName: json['farmer_name'] as String? ?? 'Farmer',
        cropName: json['crop_name'] as String? ?? 'Produce',
        batchId: json['batch_id'] as String? ?? '#4092',
        weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
        tonKm: (json['ton_km'] as num?)?.toDouble() ?? 0.0,
        costShare: (json['payout'] as num?)?.toDouble() ??
            (json['cost_share'] as num?)?.toDouble() ??
            0.0,
      );
}

class TripReview {
  final String author;
  final double rating;
  final String comment;
  final String role; // 'Farmer' or 'Buyer'
  final DateTime date;

  const TripReview({
    required this.author,
    required this.rating,
    required this.comment,
    required this.role,
    required this.date,
  });

  factory TripReview.fromJson(Map<String, dynamic> json) => TripReview(
        author: json['author'] as String? ?? 'Verified Partner',
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        comment: json['comment'] as String? ?? 'Punctual and reliable delivery.',
        role: json['role'] as String? ?? 'Farmer',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'rating': rating,
        'comment': comment,
        'role': role,
        'date': date.toIso8601String(),
      };
}

class TripEarningsRecord {
  final String id;
  final String tripId;
  final double totalPayout;
  final String status; // SETTLED, IN_ESCROW, PROCESSING
  final DateTime createdAt;
  final String destinationName;
  final int durationMin;
  final double distanceKm;
  final String vehicleTier;

  // Combined Logistics Pot Model (Porter/Dunzo Pooled Agri Model)
  final double buyerLogisticsFee;
  final double farmerPooledFee;
  final double platformCommission;
  final List<FarmerTonKmContribution> tonKmContributions;
  final List<TripReview> reviews;

  double get totalPot => buyerLogisticsFee + farmerPooledFee;

  const TripEarningsRecord({
    required this.id,
    required this.tripId,
    required this.totalPayout,
    required this.status,
    required this.createdAt,
    this.destinationName = 'Reliance Fresh Regional DC, Dock 3',
    this.durationMin = 135,
    this.distanceKm = 46.5,
    this.vehicleTier = 'Tata Ace (Small)',
    this.buyerLogisticsFee = 2400.0,
    this.farmerPooledFee = 850.0,
    this.platformCommission = 250.0,
    required this.tonKmContributions,
    this.reviews = const [],
  });

  factory TripEarningsRecord.fromJson(Map<String, dynamic> json) {
    final dynamic rawSplits = json['ton_km_splits'];
    final List list = (rawSplits is List)
        ? rawSplits
        : (rawSplits is String)
            ? (jsonDecode(rawSplits) as List)
            : [];
    final reviewsJson = (json['reviews'] is List) ? (json['reviews'] as List) : [];
    final payout = (json['total_payout'] as num?)?.toDouble() ?? 3000.0;

    return TripEarningsRecord(
      id: json['id'] as String? ?? 'EARN-01',
      tripId: json['trip_id'] as String? ?? 'TRIP-01',
      totalPayout: payout,
      status: json['status'] as String? ?? 'SETTLED',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      destinationName:
          json['destination_name'] as String? ?? 'Reliance Fresh Regional DC, Dock 3',
      durationMin: json['duration_min'] as int? ?? 135,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 46.5,
      vehicleTier: json['vehicle_tier'] as String? ?? 'Tata Ace (Small)',
      buyerLogisticsFee: (json['buyer_logistics_fee'] as num?)?.toDouble() ??
          (payout * 0.78),
      farmerPooledFee: (json['farmer_pooled_fee'] as num?)?.toDouble() ??
          (payout * 0.30),
      platformCommission:
          (json['platform_commission'] as num?)?.toDouble() ??
              (payout * 0.08),
      tonKmContributions: list
          .map((e) =>
              FarmerTonKmContribution.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: reviewsJson
          .map((r) => TripReview.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EscrowWallet {
  final double availableBalance;
  final double inEscrowPending;
  final String currency;
  final String? upiId;

  const EscrowWallet({
    required this.availableBalance,
    required this.inEscrowPending,
    this.currency = 'INR',
    this.upiId,
  });

  factory EscrowWallet.fromJson(Map<String, dynamic> json) => EscrowWallet(
        availableBalance: (json['balance'] as num?)?.toDouble() ?? 0.0,
        inEscrowPending: (json['pending'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'INR',
        upiId: json['upi_id'] as String?,
      );
}
