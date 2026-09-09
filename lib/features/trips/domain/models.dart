// lib/features/trips/domain/models.dart
import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

enum TripStatus {
  assigned,
  enRoutePickup,
  inTransit,
  delivered,
  cancelled;

  String get displayLabel {
    switch (this) {
      case TripStatus.assigned:
        return 'Assigned';
      case TripStatus.enRoutePickup:
        return 'En Route — Pickup';
      case TripStatus.inTransit:
        return 'In Transit';
      case TripStatus.delivered:
        return 'Delivered';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  static TripStatus fromString(String s) {
    switch (s.toUpperCase()) {
      case 'ASSIGNED':
        return TripStatus.assigned;
      case 'EN_ROUTE_PICKUP':
        return TripStatus.enRoutePickup;
      case 'IN_TRANSIT':
        return TripStatus.inTransit;
      case 'DELIVERED':
        return TripStatus.delivered;
      case 'CANCELLED':
        return TripStatus.cancelled;
      default:
        return TripStatus.assigned;
    }
  }

  String get apiString {
    switch (this) {
      case TripStatus.assigned:
        return 'ASSIGNED';
      case TripStatus.enRoutePickup:
        return 'EN_ROUTE_PICKUP';
      case TripStatus.inTransit:
        return 'IN_TRANSIT';
      case TripStatus.delivered:
        return 'DELIVERED';
      case TripStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

class DropoffLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? contactPhone;

  const DropoffLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactPhone,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  factory DropoffLocation.fromJson(Map<String, dynamic> json) =>
      DropoffLocation(
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        contactPhone: json['contact'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'contact': contactPhone,
      };
}

class TonKmSplit {
  final String stopId;
  final String farmerName;
  final double weightKg;
  final double distanceKm;
  final double tonKm;
  final double payout;

  const TonKmSplit({
    required this.stopId,
    required this.farmerName,
    required this.weightKg,
    required this.distanceKm,
    required this.tonKm,
    required this.payout,
  });

  factory TonKmSplit.fromJson(Map<String, dynamic> json) => TonKmSplit(
        stopId: json['stop_id'] as String? ?? '',
        farmerName: json['farmer_name'] as String,
        weightKg: (json['weight_kg'] as num).toDouble(),
        distanceKm: (json['distance_km'] as num).toDouble(),
        tonKm: (json['ton_km'] as num).toDouble(),
        payout: (json['payout'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'stop_id': stopId,
        'farmer_name': farmerName,
        'weight_kg': weightKg,
        'distance_km': distanceKm,
        'ton_km': tonKm,
        'payout': payout,
      };
}

class PickupWaypoint {
  final String stopId;
  final int stopOrder;
  final String farmerName;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final double weightKg;
  final String cropName;
  final String batchQrCode;
  final String batchId;
  final bool isPickedUp;
  final bool isDeliveryVerified;
  final String? address;
  final DateTime? pickedUpAt;

  const PickupWaypoint({
    required this.stopId,
    required this.stopOrder,
    required this.farmerName,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
    required this.weightKg,
    required this.cropName,
    required this.batchQrCode,
    this.batchId = '#4092',
    this.isPickedUp = false,
    this.isDeliveryVerified = false,
    this.address,
    this.pickedUpAt,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  PickupWaypoint copyWith({
    bool? isPickedUp,
    bool? isDeliveryVerified,
    DateTime? pickedUpAt,
  }) =>
      PickupWaypoint(
        stopId: stopId,
        stopOrder: stopOrder,
        farmerName: farmerName,
        contactPhone: contactPhone,
        latitude: latitude,
        longitude: longitude,
        weightKg: weightKg,
        cropName: cropName,
        batchQrCode: batchQrCode,
        batchId: batchId,
        isPickedUp: isPickedUp ?? this.isPickedUp,
        isDeliveryVerified: isDeliveryVerified ?? this.isDeliveryVerified,
        address: address,
        pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      );

  factory PickupWaypoint.fromJson(Map<String, dynamic> json) => PickupWaypoint(
        stopId: json['stop_id'] as String,
        stopOrder: json['stop_order'] as int? ?? 0,
        farmerName: json['farmer_name'] as String,
        contactPhone: json['contact_phone'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        weightKg: (json['weight_kg'] as num).toDouble(),
        cropName: json['crop_name'] as String,
        batchQrCode: json['batch_qr_code'] as String,
        batchId: json['batch_id'] as String? ??
            '#${(json['stop_id']?.hashCode.abs() ?? 4092) % 9000 + 1000}',
        isPickedUp: json['is_picked_up'] as bool? ?? false,
        isDeliveryVerified: json['is_delivery_verified'] as bool? ?? false,
        address: json['address'] as String?,
        pickedUpAt: json['picked_up_at'] != null
            ? DateTime.tryParse(json['picked_up_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'stop_id': stopId,
        'stop_order': stopOrder,
        'farmer_name': farmerName,
        'contact_phone': contactPhone,
        'latitude': latitude,
        'longitude': longitude,
        'weight_kg': weightKg,
        'crop_name': cropName,
        'batch_qr_code': batchQrCode,
        'batch_id': batchId,
        'is_picked_up': isPickedUp,
        'is_delivery_verified': isDeliveryVerified,
        'address': address,
        'picked_up_at': pickedUpAt?.toIso8601String(),
      };
}

class DeliveryWaypoint {
  final String stopId;
  final int stopOrder;
  final String buyerName;
  final String buyerType; // e.g. 'Retail Supermarket DC', 'Dark Store Hub', 'University Hostel Mess'
  final String address;
  final String contactPhone;
  final double latitude;
  final double longitude;
  final double weightKg;
  final String cropName;
  final String batchId;
  final bool isDelivered;
  final DateTime? deliveredAt;
  final String handoverOtp;

  const DeliveryWaypoint({
    required this.stopId,
    required this.stopOrder,
    required this.buyerName,
    required this.buyerType,
    required this.address,
    required this.contactPhone,
    required this.latitude,
    required this.longitude,
    required this.weightKg,
    required this.cropName,
    required this.batchId,
    this.isDelivered = false,
    this.deliveredAt,
    this.handoverOtp = '4092',
  });

  LatLng get latLng => LatLng(latitude, longitude);

  DeliveryWaypoint copyWith({
    bool? isDelivered,
    DateTime? deliveredAt,
  }) =>
      DeliveryWaypoint(
        stopId: stopId,
        stopOrder: stopOrder,
        buyerName: buyerName,
        buyerType: buyerType,
        address: address,
        contactPhone: contactPhone,
        latitude: latitude,
        longitude: longitude,
        weightKg: weightKg,
        cropName: cropName,
        batchId: batchId,
        isDelivered: isDelivered ?? this.isDelivered,
        deliveredAt: deliveredAt ?? this.deliveredAt,
        handoverOtp: handoverOtp,
      );

  factory DeliveryWaypoint.fromJson(Map<String, dynamic> json) =>
      DeliveryWaypoint(
        stopId: json['stop_id'] as String? ?? 'DELIV-001',
        stopOrder: json['stop_order'] as int? ?? 1,
        buyerName: json['buyer_name'] as String? ?? 'Bulk Buyer DC',
        buyerType: json['buyer_type'] as String? ?? 'Commercial Buyer',
        address: json['address'] as String? ?? '',
        contactPhone: json['contact_phone'] as String? ?? '+919876500000',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 20.0059,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 73.7799,
        weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 500.0,
        cropName: json['crop_name'] as String? ?? 'Produce',
        batchId: json['batch_id'] as String? ?? '#4092',
        isDelivered: json['is_delivered'] as bool? ?? false,
        deliveredAt: json['delivered_at'] != null
            ? DateTime.tryParse(json['delivered_at'] as String)
            : null,
        handoverOtp: json['handover_otp'] as String? ?? '4092',
      );

  Map<String, dynamic> toJson() => {
        'stop_id': stopId,
        'stop_order': stopOrder,
        'buyer_name': buyerName,
        'buyer_type': buyerType,
        'address': address,
        'contact_phone': contactPhone,
        'latitude': latitude,
        'longitude': longitude,
        'weight_kg': weightKg,
        'crop_name': cropName,
        'batch_id': batchId,
        'is_delivered': isDelivered,
        'delivered_at': deliveredAt?.toIso8601String(),
        'handover_otp': handoverOtp,
      };
}

class RideTrip {
  final String tripId;
  final String vehicleTier;
  final TripStatus status;
  final double totalTripCost;
  final double totalWeightKg;
  final int estimatedDurationMin;
  final double distanceKm;
  final List<PickupWaypoint> waypoints;
  final DropoffLocation destination;
  final List<DeliveryWaypoint> deliveryStops;
  final List<TonKmSplit> tonKmSplits;
  final DateTime assignedAt;
  final DateTime? completedAt;

  // Combined Logistics Pot Model (Porter / WheelsEye / Dunzo Pooled Model)
  final double buyerLogisticsFee;
  final double farmerPooledFee;
  final double platformCommission;

  double get totalLogisticsPot => buyerLogisticsFee + farmerPooledFee;

  const RideTrip({
    required this.tripId,
    required this.vehicleTier,
    required this.status,
    required this.totalTripCost,
    required this.totalWeightKg,
    required this.estimatedDurationMin,
    required this.distanceKm,
    required this.waypoints,
    required this.destination,
    this.deliveryStops = const [],
    required this.tonKmSplits,
    required this.assignedAt,
    this.completedAt,
    this.buyerLogisticsFee = 2400.0,
    this.farmerPooledFee = 850.0,
    this.platformCommission = 250.0,
  });

  int get pendingPickupsCount =>
      waypoints.where((w) => !w.isPickedUp).length;

  int get completedPickupsCount =>
      waypoints.where((w) => w.isPickedUp).length;

  int get verifiedDeliveryCount =>
      waypoints.where((w) => w.isDeliveryVerified).length;

  bool get allDeliveriesVerified =>
      waypoints.isNotEmpty && waypoints.every((w) => w.isDeliveryVerified);

  PickupWaypoint? get nextWaypoint =>
      waypoints.where((w) => !w.isPickedUp).isNotEmpty
          ? waypoints.firstWhere((w) => !w.isPickedUp)
          : null;

  int get pendingDeliveriesCount =>
      deliveryStops.where((d) => !d.isDelivered).length;

  int get completedDeliveriesCount =>
      deliveryStops.where((d) => d.isDelivered).length;

  bool get allDeliveriesDone =>
      deliveryStops.isNotEmpty && deliveryStops.every((d) => d.isDelivered);

  DeliveryWaypoint? get nextDeliveryStop =>
      deliveryStops.where((d) => !d.isDelivered).isNotEmpty
          ? deliveryStops.firstWhere((d) => !d.isDelivered)
          : null;

  RideTrip copyWith({
    TripStatus? status,
    List<PickupWaypoint>? waypoints,
    List<DeliveryWaypoint>? deliveryStops,
    DateTime? completedAt,
    double? buyerLogisticsFee,
    double? farmerPooledFee,
    double? platformCommission,
  }) =>
      RideTrip(
        tripId: tripId,
        vehicleTier: vehicleTier,
        status: status ?? this.status,
        totalTripCost: totalTripCost,
        totalWeightKg: totalWeightKg,
        estimatedDurationMin: estimatedDurationMin,
        distanceKm: distanceKm,
        waypoints: waypoints ?? this.waypoints,
        destination: destination,
        deliveryStops: deliveryStops ?? this.deliveryStops,
        tonKmSplits: tonKmSplits,
        assignedAt: assignedAt,
        completedAt: completedAt ?? this.completedAt,
        buyerLogisticsFee: buyerLogisticsFee ?? this.buyerLogisticsFee,
        farmerPooledFee: farmerPooledFee ?? this.farmerPooledFee,
        platformCommission: platformCommission ?? this.platformCommission,
      );

  factory RideTrip.fromJson(Map<String, dynamic> json) {
    final waypointsJson = json['waypoints'] as List<dynamic>? ?? [];
    final deliveryJson = json['delivery_stops'] as List<dynamic>? ?? [];
    final splitsJson = json['ton_km_splits'] as List<dynamic>? ?? [];
    final totalCost = (json['total_trip_cost'] as num).toDouble();
    final dest = DropoffLocation.fromJson(
        json['destination'] as Map<String, dynamic>);

    final stops = deliveryJson.isNotEmpty
        ? deliveryJson
            .map((d) => DeliveryWaypoint.fromJson(d as Map<String, dynamic>))
            .toList()
        : [
            DeliveryWaypoint(
              stopId: 'DELIV-001',
              stopOrder: 1,
              buyerName: dest.name,
              buyerType: 'Bulk Buyer Distribution Center',
              address: dest.address,
              contactPhone: dest.contactPhone ?? '+919823451122',
              latitude: dest.latitude,
              longitude: dest.longitude,
              weightKg: (json['total_weight_kg'] as num?)?.toDouble() ?? 500.0,
              cropName: 'Assorted Fresh Produce',
              batchId: '#4092',
              handoverOtp: '4092',
            ),
          ];

    return RideTrip(
      tripId: json['trip_id'] as String,
      vehicleTier: json['vehicle_tier'] as String? ?? 'SMALL',
      status: TripStatus.fromString(json['status'] as String? ?? 'ASSIGNED'),
      totalTripCost: totalCost,
      totalWeightKg: (json['total_weight_kg'] as num?)?.toDouble() ?? 0,
      estimatedDurationMin: json['estimated_duration_min'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      waypoints: waypointsJson
          .map((w) => PickupWaypoint.fromJson(w as Map<String, dynamic>))
          .toList(),
      destination: dest,
      deliveryStops: stops,
      tonKmSplits: splitsJson
          .map((s) => TonKmSplit.fromJson(s as Map<String, dynamic>))
          .toList(),
      assignedAt: DateTime.tryParse(json['assigned_at'] as String? ?? '') ??
          DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      buyerLogisticsFee: (json['buyer_logistics_fee'] as num?)?.toDouble() ??
          (totalCost * 0.75),
      farmerPooledFee: (json['farmer_pooled_fee'] as num?)?.toDouble() ??
          (totalCost * 0.33),
      platformCommission:
          (json['platform_commission'] as num?)?.toDouble() ??
              (totalCost * 0.08),
    );
  }

  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'vehicle_tier': vehicleTier,
        'status': status.apiString,
        'total_trip_cost': totalTripCost,
        'total_weight_kg': totalWeightKg,
        'estimated_duration_min': estimatedDurationMin,
        'distance_km': distanceKm,
        'waypoints': waypoints.map((w) => w.toJson()).toList(),
        'destination': destination.toJson(),
        'delivery_stops': deliveryStops.map((d) => d.toJson()).toList(),
        'ton_km_splits': tonKmSplits.map((s) => s.toJson()).toList(),
        'assigned_at': assignedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'buyer_logistics_fee': buyerLogisticsFee,
        'farmer_pooled_fee': farmerPooledFee,
        'platform_commission': platformCommission,
        'total_logistics_pot': totalLogisticsPot,
      };
}

// Ton-Km formula: C_i = TotalCost × (W_i × D_i) / Σ(W_j × D_j)
double calculateTonKmPayout({
  required double totalTripCost,
  required double weightKg,
  required double distanceKm,
  required List<({double weightKg, double distanceKm})> allSegments,
}) {
  final numerator = (weightKg / 1000) * distanceKm;
  final denominator = allSegments.fold<double>(
    0,
    (sum, seg) => sum + (seg.weightKg / 1000) * seg.distanceKm,
  );
  if (denominator == 0) return 0;
  return totalTripCost * (numerator / denominator);
}

// Haversine geofence check
double haversineDistanceMeters({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const earthR = 6371000.0; // metres
  final dLat = (lat2 - lat1) * math.pi / 180.0;
  final dLon = (lon2 - lon1) * math.pi / 180.0;
  final rLat1 = lat1 * math.pi / 180.0;
  final rLat2 = lat2 * math.pi / 180.0;

  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rLat1) * math.cos(rLat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthR * c;
}
