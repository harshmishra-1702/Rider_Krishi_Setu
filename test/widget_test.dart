// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/core/localization/app_strings.dart';
import 'package:rider_app/features/auth/domain/user_role.dart';
import 'package:rider_app/features/trips/domain/models.dart';
import 'package:rider_app/features/auth/domain/models.dart';

void main() {
  group('KrishiSetu Logistics & Math Engine Tests', () {
    test('Ton-Kilometer split calculation distributes cost proportionally', () {
      // Scenario: Total Trip Cost = ₹3000
      // Farmer 1: 500 kg (0.5 T), 20 km -> 10 Ton-Km
      // Farmer 2: 1500 kg (1.5 T), 30 km -> 45 Ton-Km
      // Total Ton-Km = 55 Ton-Km
      // Farmer 1 Payout: 3000 * (10 / 55) = ₹545.4545...
      // Farmer 2 Payout: 3000 * (45 / 55) = ₹2454.5454...

      final segments = [
        (weightKg: 500.0, distanceKm: 20.0),
        (weightKg: 1500.0, distanceKm: 30.0),
      ];

      final cost1 = calculateTonKmPayout(
        totalTripCost: 3000.0,
        weightKg: 500.0,
        distanceKm: 20.0,
        allSegments: segments,
      );

      final cost2 = calculateTonKmPayout(
        totalTripCost: 3000.0,
        weightKg: 1500.0,
        distanceKm: 30.0,
        allSegments: segments,
      );

      expect(cost1, closeTo(545.45, 0.05));
      expect(cost2, closeTo(2454.55, 0.05));
      expect(cost1 + cost2, closeTo(3000.0, 0.01));
    });

    test('Haversine distance calculation detects geofence within 100m', () {
      // Nashik APMC Market coordinates
      const apmcLat = 20.0059;
      const apmcLng = 73.7799;

      // Point ~50 meters away
      const nearbyLat = 20.0062;
      const nearbyLng = 73.7802;

      // Point ~500 meters away
      const farLat = 20.0100;
      const farLng = 73.7850;

      final distNearby = haversineDistanceMeters(
        lat1: apmcLat,
        lon1: apmcLng,
        lat2: nearbyLat,
        lon2: nearbyLng,
      );

      final distFar = haversineDistanceMeters(
        lat1: apmcLat,
        lon1: apmcLng,
        lat2: farLat,
        lon2: farLng,
      );

      expect(distNearby, lessThan(100.0));
      expect(distFar, greaterThan(100.0));
    });

    test('Vehicle Tier classification has valid capacities and labels', () {
      expect(VehicleTier.micro.capacityKg, 250);
      expect(VehicleTier.small.capacityKg, 1500);
      expect(VehicleTier.medium.capacityKg, 5000);
      expect(VehicleTier.large.capacityKg, 10000);

      expect(VehicleTier.fromString('micro'), VehicleTier.micro);
      expect(VehicleTier.fromString('small'), VehicleTier.small);
      expect(VehicleTier.fromString('medium'), VehicleTier.medium);
      expect(VehicleTier.fromString('large'), VehicleTier.large);
    });

    test('Privacy rule: Aadhaar is never exposed in plain digits', () {
      const driver = Driver(
        driverId: 'DRV-001',
        name: 'Suresh',
        phone: '+919876543210',
        licenseNumber: 'MH-12-123',
        vehicleTier: VehicleTier.small,
        vehicleNumber: 'MH-12-AB-1234',
        vehicleModel: 'Tata Ace',
        capacityKg: 1000,
      );

      expect(driver.aadhaar, equals('[Aadhaar Redacted]'));
      final json = driver.toJson();
      expect(json['aadhaar'], equals('[Aadhaar Redacted]'));
    });

    test('UserRole contains all 4 required ecosystem roles', () {
      expect(UserRole.values.length, 4);
      expect(UserRole.values, contains(UserRole.consumer));
      expect(UserRole.values, contains(UserRole.bulkBuyer));
      expect(UserRole.values, contains(UserRole.farmer));
      expect(UserRole.values, contains(UserRole.rider));
      expect(UserRole.rider.id, 'rider');
      expect(UserRole.farmer.id, 'farmer');
    });

    test('AppStrings supports all 6 regional languages with CVRP terminology', () {
      final languages = [
        AppStrings.english,
        AppStrings.hindi,
        AppStrings.marathi,
        AppStrings.tamil,
        AppStrings.telugu,
        AppStrings.kannada,
      ];

      for (final s in languages) {
        expect(s.selectRoleTitle.isNotEmpty, isTrue);
        expect(s.selectLanguage.isNotEmpty, isTrue);
        expect(s.loginTitle.isNotEmpty, isTrue);
        expect(s.cvrpRunAssigned.isNotEmpty, isTrue);
        expect(s.guaranteedPayout.isNotEmpty, isTrue);
        expect(s.milestones.isNotEmpty, isTrue);
        expect(s.scanQr.isNotEmpty, isTrue);
        expect(s.escrowBalance.isNotEmpty, isTrue);
      }
    });

    test('Combined Logistics Pot & Ton-Km formula model calculates net driver payout', () {
      // Porter / WheelsEye / Dunzo pooled model
      const buyerFee = 2350.0;
      const farmerPooledFee = 900.0;
      const totalPot = buyerFee + farmerPooledFee; // ₹3,250
      const platformCommission = 250.0;
      const driverPayout = totalPot - platformCommission; // ₹3,000

      expect(totalPot, 3250.0);
      expect(driverPayout, 3000.0);

      // Farmer Pooled Share Ton-Km split:
      // Farmer 1: 500 kg, 14.2 km -> 7.1 Ton-Km
      // Farmer 2: 750 kg, 18.5 km -> 13.88 Ton-Km
      // Farmer 3: 750 kg, 13.8 km -> 10.35 Ton-Km
      // Total Ton-Km = 31.33
      final segments = [
        (weightKg: 500.0, distanceKm: 14.2),
        (weightKg: 750.0, distanceKm: 18.5),
        (weightKg: 750.0, distanceKm: 13.8),
      ];

      final f1Share = calculateTonKmPayout(
        totalTripCost: farmerPooledFee,
        weightKg: 500.0,
        distanceKm: 14.2,
        allSegments: segments,
      );
      final f2Share = calculateTonKmPayout(
        totalTripCost: farmerPooledFee,
        weightKg: 750.0,
        distanceKm: 18.5,
        allSegments: segments,
      );
      final f3Share = calculateTonKmPayout(
        totalTripCost: farmerPooledFee,
        weightKg: 750.0,
        distanceKm: 13.8,
        allSegments: segments,
      );

      expect(f1Share + f2Share + f3Share, closeTo(farmerPooledFee, 0.01));
    });

    test('Batch ID low-tech labeling and delivery verification matching', () {
      const wp1 = PickupWaypoint(
        stopId: 'STOP-001',
        stopOrder: 1,
        farmerName: 'Ramesh Kumar',
        contactPhone: '+919823456789',
        latitude: 20.1234,
        longitude: 73.8901,
        weightKg: 500.0,
        cropName: 'Tomatoes',
        batchQrCode: 'BATCH-TOM-7821',
        batchId: '#4092',
        isPickedUp: true,
        isDeliveryVerified: false,
      );

      expect(wp1.batchId, '#4092');
      expect(wp1.isDeliveryVerified, isFalse);

      final verifiedWp1 = wp1.copyWith(isDeliveryVerified: true);
      expect(verifiedWp1.isDeliveryVerified, isTrue);

      final trip = RideTrip(
        tripId: 'TRIP-KS-TEST',
        vehicleTier: 'SMALL',
        totalTripCost: 3000.0,
        buyerLogisticsFee: 2350.0,
        farmerPooledFee: 900.0,
        platformCommission: 250.0,
        status: TripStatus.inTransit,
        totalWeightKg: 500.0,
        estimatedDurationMin: 45,
        distanceKm: 25.0,
        assignedAt: DateTime.now(),
        destination: const DropoffLocation(
          name: 'Nashik APMC',
          address: 'Market Yard',
          latitude: 20.0,
          longitude: 73.0,
          contactPhone: '+91253',
        ),
        tonKmSplits: const [],
        waypoints: [wp1],
      );

      expect(trip.allDeliveriesVerified, isFalse);
      expect(trip.verifiedDeliveryCount, 0);

      final tripVerified = trip.copyWith(waypoints: [verifiedWp1]);
      expect(tripVerified.allDeliveriesVerified, isTrue);
      expect(tripVerified.verifiedDeliveryCount, 1);
      expect(tripVerified.totalLogisticsPot, 3250.0);
    });
  });
}
