// lib/features/verification/domain/models.dart

class BatchVerification {
  final String batchId;
  final String stopId;
  final String crop;
  final double weightKg;
  final String grade;
  final String farmerName;
  final DateTime verifiedAt;

  const BatchVerification({
    required this.batchId,
    required this.stopId,
    required this.crop,
    required this.weightKg,
    required this.grade,
    required this.farmerName,
    required this.verifiedAt,
  });

  factory BatchVerification.fromJson(
    Map<String, dynamic> json, {
    String stopId = '',
  }) =>
      BatchVerification(
        batchId: json['batch_id'] as String? ?? 'BATCH-KS-AUTO',
        stopId: stopId,
        crop: json['crop'] as String? ?? 'Produce',
        weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
        grade: json['grade'] as String? ?? 'A',
        farmerName: json['farmer_name'] as String? ?? 'Farmer',
        verifiedAt: DateTime.tryParse(json['verified_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

class DeliveryProof {
  final String tripId;
  final String? localPhotoPath;
  final String? remotePhotoUrl;
  final double latitude;
  final double longitude;
  final double distanceToDestinationMeters;
  final bool isGeofencePassed;
  final String? buyerOtp;
  final DateTime? deliveredAt;

  const DeliveryProof({
    required this.tripId,
    this.localPhotoPath,
    this.remotePhotoUrl,
    required this.latitude,
    required this.longitude,
    required this.distanceToDestinationMeters,
    required this.isGeofencePassed,
    this.buyerOtp,
    this.deliveredAt,
  });

  DeliveryProof copyWith({
    String? localPhotoPath,
    String? remotePhotoUrl,
    double? latitude,
    double? longitude,
    double? distanceToDestinationMeters,
    bool? isGeofencePassed,
    String? buyerOtp,
    DateTime? deliveredAt,
  }) =>
      DeliveryProof(
        tripId: tripId,
        localPhotoPath: localPhotoPath ?? this.localPhotoPath,
        remotePhotoUrl: remotePhotoUrl ?? this.remotePhotoUrl,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        distanceToDestinationMeters:
            distanceToDestinationMeters ?? this.distanceToDestinationMeters,
        isGeofencePassed: isGeofencePassed ?? this.isGeofencePassed,
        buyerOtp: buyerOtp ?? this.buyerOtp,
        deliveredAt: deliveredAt ?? this.deliveredAt,
      );
}
