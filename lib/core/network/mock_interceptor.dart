// lib/core/network/mock_interceptor.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_constants.dart';

/// Intercepts all requests and returns rich realistic mock data when [AppConstants.useMockApi] is true.
class MockInterceptor extends Interceptor {
  int _offerIndex = 0;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) {
    if (!AppConstants.useMockApi) {
      return handler.next(options);
    }

    final path = options.path;
    final method = options.method.toUpperCase();

    // Send OTP
    if (path.contains('/auth/driver/send-otp') && method == 'POST') {
      return handler.resolve(_mockResponse(
        options,
        {'success': true, 'message': 'OTP sent to registered mobile number'},
      ));
    }

    // Verify OTP
    if (path.contains('/auth/driver/verify-otp') && method == 'POST') {
      return handler.resolve(_mockResponse(options, {
        'token': 'mock_jwt_token_krishisetu_2024',
        'driver_id': 'DRV-KS-0042',
        'is_new_user': false,
      }));
    }

    // Driver profile
    if (path.contains('/auth/driver/profile')) {
      if (method == 'GET') {
        return handler.resolve(_mockResponse(options, _mockDriverProfile()));
      }
      if (method == 'POST' || method == 'PUT') {
        return handler.resolve(_mockResponse(options, _mockDriverProfile()));
      }
    }

    // Ride offers (cycles between presets or returns by scenario)
    if (path.contains('/logistics/rides/offers') && method == 'GET') {
      final tripOffers = [
        _mockTripStandard(),
        _mockTripMegaReefer(),
        _mockTripMicroFleet(),
      ];
      final selectedOffer = tripOffers[_offerIndex % tripOffers.length];
      _offerIndex++;
      return handler.resolve(_mockResponse(options, selectedOffer));
    }

    // Accept ride
    if (path.contains('/accept') && method == 'POST') {
      return handler.resolve(_mockResponse(options, {
        'success': true,
        'trip': _mockTripStandard(),
      }));
    }

    // Reject ride
    if (path.contains('/reject') && method == 'POST') {
      return handler.resolve(
          _mockResponse(options, {'success': true, 'message': 'Trip declined'}));
    }

    // Pickup verify
    if (path.contains('/pickups/') && path.contains('/verify') &&
        method == 'POST') {
      return handler.resolve(_mockResponse(options, {
        'success': true,
        'batch': {
          'batch_id': 'BATCH-KS-7821',
          'crop': 'Tomatoes (Grade A)',
          'weight_kg': 500.0,
          'grade': 'A',
          'farmer_name': 'Ramesh Kumar',
          'farm_location': 'Khuntewadi, Dindori',
          'verified_at': DateTime.now().toIso8601String(),
        },
      }));
    }

    // Delivery photo
    if (path.contains('/deliveries/') && path.contains('/photo') &&
        method == 'POST') {
      return handler.resolve(_mockResponse(options, {
        'success': true,
        'photo_url': 'https://cdn.krishisetu.dev/proofs/mandi_dock_unloaded_produce.jpg',
      }));
    }

    // Delivery OTP confirm
    if (path.contains('/deliveries/') && path.contains('/confirm') &&
        method == 'POST') {
      return handler.resolve(_mockResponse(options, {
        'success': true,
        'status': 'DELIVERED',
        'earnings': _mockEarnings1(),
      }));
    }

    // Telemetry ping
    if (path.contains('/telemetry/ping') && method == 'POST') {
      return handler
          .resolve(_mockResponse(options, {'success': true, 'received': true}));
    }

    // Earnings
    if (path.contains('/escrow/driver/earnings') && method == 'GET') {
      return handler.resolve(_mockResponse(options, {
        'earnings_history': [
          _mockEarnings1(),
          _mockEarnings2(),
          _mockEarnings3(),
          _mockEarnings4(),
          _mockEarnings5(),
        ],
        'total_lifetime': 74500.0,
        'completed_trips_count': 34,
      }));
    }

    // Wallet balance
    if (path.contains('/escrow/driver/wallet') && method == 'GET') {
      return handler.resolve(_mockResponse(options, {
        'balance': 8450.0,
        'pending': 3000.0,
        'currency': 'INR',
        'upi_id': 'suresh.yadav@upi',
      }));
    }

    // Payout request
    if (path.contains('/escrow/driver/payout') && method == 'POST') {
      return handler.resolve(_mockResponse(options, {
        'success': true,
        'transaction_id': 'TXN-UPI-${DateTime.now().millisecondsSinceEpoch}',
        'amount': 8450.0,
        'status': 'DISBURSED',
        'bank_ref': 'BARB0NASHIK45902',
        'estimated_time': 'Instant (IMPS 24x7)',
      }));
    }

    // Fallthrough
    return handler.next(options);
  }

  Response<dynamic> _mockResponse(
      RequestOptions options, Map<String, dynamic> data) {
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: jsonEncode(data),
      headers: Headers.fromMap({'content-type': ['application/json']}),
    );
  }

  Map<String, dynamic> _mockDriverProfile() => {
        'driver_id': 'DRV-KS-0042',
        'name': 'Suresh Yadav',
        'phone': '+919876543210',
        'aadhaar': '[Aadhaar Redacted]',
        'license_number': 'MH-12-20190034521',
        'vehicle_tier': 'SMALL',
        'vehicle_number': 'MH-12-AB-1234',
        'vehicle_model': 'Tata Ace Gold',
        'capacity_kg': 1500.0,
        'rating': 4.8,
        'total_trips': 127,
        'profile_photo': null,
        'upi_id': 'suresh.yadav@upi',
        'is_online': true,
      };

  // ── Preset 1: Standard Small Commercial (Tata Ace) ────────────────────────
  Map<String, dynamic> _mockTripStandard() => {
        'trip_id': 'TRIP-KS-8921',
        'vehicle_tier': 'SMALL',
        'total_trip_cost': 3000.0,
        'buyer_logistics_fee': 2350.0,
        'farmer_pooled_fee': 900.0,
        'platform_commission': 250.0,
        'status': 'ASSIGNED',
        'total_weight_kg': 2000.0,
        'estimated_duration_min': 85,
        'distance_km': 46.5,
        'assigned_at': DateTime.now().toIso8601String(),
        'destination': {
          'name': 'Nashik APMC Mandi',
          'address': 'Market Yard, Dindori Road, Nashik-422001',
          'latitude': 20.0059,
          'longitude': 73.7799,
          'contact': '+912536002345',
        },
        'waypoints': [
          {
            'stop_id': 'STOP-001',
            'stop_order': 1,
            'farmer_name': 'Ramesh Kumar',
            'contact_phone': '+919823456789',
            'latitude': 20.1234,
            'longitude': 73.8901,
            'weight_kg': 500.0,
            'crop_name': 'Tomatoes',
            'batch_qr_code': 'BATCH-TOM-7821',
            'batch_id': '#4092',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Khuntewadi Farm, Dindori Tehsil',
          },
          {
            'stop_id': 'STOP-002',
            'stop_order': 2,
            'farmer_name': 'Priya Patil',
            'contact_phone': '+919876123456',
            'latitude': 20.0987,
            'longitude': 73.8543,
            'weight_kg': 750.0,
            'crop_name': 'Red Onions',
            'batch_qr_code': 'BATCH-ONI-7822',
            'batch_id': '#7183',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Sawargaon Gate, Niphad',
          },
          {
            'stop_id': 'STOP-003',
            'stop_order': 3,
            'farmer_name': 'Suresh Pawar',
            'contact_phone': '+919765432198',
            'latitude': 20.0654,
            'longitude': 73.8234,
            'weight_kg': 750.0,
            'crop_name': 'Thompson Grapes',
            'batch_qr_code': 'BATCH-GRP-7823',
            'batch_id': '#8821',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Pimpalgaon Baswant, Niphad',
          },
        ],
        'ton_km_splits': [
          {
            'stop_id': 'STOP-001',
            'farmer_name': 'Ramesh Kumar',
            'crop_name': 'Tomatoes',
            'batch_id': '#4092',
            'weight_kg': 500.0,
            'distance_km': 14.2,
            'ton_km': 7.10,
            'payout': 545.45,
          },
          {
            'stop_id': 'STOP-002',
            'farmer_name': 'Priya Patil',
            'crop_name': 'Red Onions',
            'weight_kg': 750.0,
            'distance_km': 18.5,
            'ton_km': 13.88,
            'payout': 1067.31,
          },
          {
            'stop_id': 'STOP-003',
            'farmer_name': 'Suresh Pawar',
            'crop_name': 'Thompson Grapes',
            'weight_kg': 750.0,
            'distance_km': 13.8,
            'ton_km': 10.35,
            'payout': 1387.24,
          },
        ],
      };

  // ── Preset 2: Heavy Commercial Reefer Run (Eicher Pro 10T) ────────────────
  Map<String, dynamic> _mockTripMegaReefer() => {
        'trip_id': 'TRIP-KS-9054',
        'vehicle_tier': 'LARGE',
        'total_trip_cost': 18500.0,
        'buyer_logistics_fee': 14800.0,
        'farmer_pooled_fee': 5200.0,
        'platform_commission': 1500.0,
        'status': 'ASSIGNED',
        'total_weight_kg': 8000.0,
        'estimated_duration_min': 240,
        'distance_km': 185.0,
        'assigned_at': DateTime.now().toIso8601String(),
        'destination': {
          'name': 'Vashi APMC Mega Mandi',
          'address': 'Sector 19, Turbhe, Navi Mumbai-400703',
          'latitude': 19.0760,
          'longitude': 72.9980,
          'contact': '+912227891234',
        },
        'waypoints': [
          {
            'stop_id': 'STOP-101',
            'stop_order': 1,
            'farmer_name': 'Sanjay Shinde',
            'contact_phone': '+919822334455',
            'latitude': 20.4850,
            'longitude': 74.0150,
            'weight_kg': 2500.0,
            'crop_name': 'Bhagwa Pomegranates',
            'batch_qr_code': 'BATCH-POM-9101',
            'batch_id': '#9101',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Kalwan Horticulture Hub',
          },
          {
            'stop_id': 'STOP-102',
            'stop_order': 2,
            'farmer_name': 'Vitthal Gaikwad',
            'contact_phone': '+919833445566',
            'latitude': 20.5920,
            'longitude': 74.1980,
            'weight_kg': 2000.0,
            'crop_name': 'Green Capsicum',
            'batch_qr_code': 'BATCH-CAP-9102',
            'batch_id': '#9102',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Satana Polyhouse Cluster',
          },
          {
            'stop_id': 'STOP-103',
            'stop_order': 3,
            'farmer_name': 'Ganesh Jadhav',
            'contact_phone': '+919844556677',
            'latitude': 20.2500,
            'longitude': 73.7800,
            'weight_kg': 1500.0,
            'crop_name': 'Sweet Strawberries',
            'batch_qr_code': 'BATCH-STR-9103',
            'batch_id': '#9103',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Surgana Hilly Terraces',
          },
          {
            'stop_id': 'STOP-104',
            'stop_order': 4,
            'farmer_name': 'Mohan Patil',
            'contact_phone': '+919855667788',
            'latitude': 19.6950,
            'longitude': 73.5500,
            'weight_kg': 2000.0,
            'crop_name': 'Exotic Broccoli & Zucchini',
            'batch_qr_code': 'BATCH-EXO-9104',
            'batch_id': '#9104',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Igatpuri Hill Agro Cluster',
          },
        ],
        'ton_km_splits': [
          {
            'stop_id': 'STOP-101',
            'farmer_name': 'Sanjay Shinde',
            'crop_name': 'Bhagwa Pomegranates',
            'batch_id': '#9101',
            'weight_kg': 2500.0,
            'distance_km': 185.0,
            'ton_km': 462.5,
            'payout': 6250.00,
          },
          {
            'stop_id': 'STOP-102',
            'farmer_name': 'Vitthal Gaikwad',
            'crop_name': 'Green Capsicum',
            'batch_id': '#9102',
            'weight_kg': 2000.0,
            'distance_km': 170.0,
            'ton_km': 340.0,
            'payout': 4600.00,
          },
          {
            'stop_id': 'STOP-103',
            'farmer_name': 'Ganesh Jadhav',
            'crop_name': 'Sweet Strawberries',
            'batch_id': '#9103',
            'weight_kg': 1500.0,
            'distance_km': 150.0,
            'ton_km': 225.0,
            'payout': 3050.00,
          },
          {
            'stop_id': 'STOP-104',
            'farmer_name': 'Mohan Patil',
            'crop_name': 'Exotic Vegetables',
            'batch_id': '#9104',
            'weight_kg': 2000.0,
            'distance_km': 120.0,
            'ton_km': 240.0,
            'payout': 4600.00,
          },
        ],
      };

  // ── Preset 3: Micro-Fleet E-Cart Short Haul (Mahindra Treo Zor) ────────────
  Map<String, dynamic> _mockTripMicroFleet() => {
        'trip_id': 'TRIP-KS-3012',
        'vehicle_tier': 'MICRO',
        'total_trip_cost': 850.0,
        'buyer_logistics_fee': 680.0,
        'farmer_pooled_fee': 240.0,
        'platform_commission': 70.0,
        'status': 'ASSIGNED',
        'total_weight_kg': 350.0,
        'estimated_duration_min': 35,
        'distance_km': 14.5,
        'assigned_at': DateTime.now().toIso8601String(),
        'destination': {
          'name': 'Niphad FPO Packhouse & Pre-cooling Hub',
          'address': 'State Highway 28, Niphad-422303',
          'latitude': 20.0800,
          'longitude': 74.1100,
          'contact': '+912550244111',
        },
        'waypoints': [
          {
            'stop_id': 'STOP-201',
            'stop_order': 1,
            'farmer_name': 'Baburao Kadam',
            'contact_phone': '+919922114433',
            'latitude': 20.0910,
            'longitude': 74.1350,
            'weight_kg': 150.0,
            'crop_name': 'Organic Spinach',
            'batch_qr_code': 'BATCH-VEG-201',
            'batch_id': '#3301',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Vinchur Green Belt',
          },
          {
            'stop_id': 'STOP-202',
            'stop_order': 2,
            'farmer_name': 'Sunita Bhor',
            'contact_phone': '+919933225544',
            'latitude': 20.0750,
            'longitude': 74.1200,
            'weight_kg': 200.0,
            'crop_name': 'Coriander & Fresh Mint',
            'batch_qr_code': 'BATCH-HRB-202',
            'batch_id': '#3302',
            'is_picked_up': false,
            'is_delivery_verified': false,
            'address': 'Lasalgaon Link Road',
          },
        ],
        'ton_km_splits': [
          {
            'stop_id': 'STOP-201',
            'farmer_name': 'Baburao Kadam',
            'crop_name': 'Organic Spinach',
            'batch_id': '#3301',
            'weight_kg': 150.0,
            'distance_km': 8.5,
            'ton_km': 1.275,
            'payout': 365.50,
          },
          {
            'stop_id': 'STOP-202',
            'farmer_name': 'Sunita Bhor',
            'crop_name': 'Coriander & Mint',
            'batch_id': '#3302',
            'weight_kg': 200.0,
            'distance_km': 6.0,
            'ton_km': 1.20,
            'payout': 484.50,
          },
        ],
      };

  // ── Settled Payouts Mock Data ──────────────────────────────────────────────
  Map<String, dynamic> _mockEarnings1() => {
        'id': 'EARN-KS-0091',
        'trip_id': 'TRIP-KS-8921',
        'total_payout': 3000.0,
        'status': 'SETTLED',
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'destination_name': 'Nashik APMC Mandi, Dock 3',
        'duration_min': 85,
        'distance_km': 46.5,
        'vehicle_tier': 'Tata Ace Gold (Small)',
        'buyer_logistics_fee': 2350.0,
        'farmer_pooled_fee': 900.0,
        'platform_commission': 250.0,
        'ton_km_splits': [
          {
            'farmer_name': 'Ramesh Kumar',
            'crop_name': 'Tomatoes',
            'batch_id': '#4092',
            'weight_kg': 500.0,
            'distance_km': 14.2,
            'ton_km': 7.10,
            'payout': 545.45,
          },
          {
            'farmer_name': 'Priya Patil',
            'crop_name': 'Red Onions',
            'batch_id': '#7183',
            'weight_kg': 750.0,
            'distance_km': 18.5,
            'ton_km': 13.88,
            'payout': 1067.31,
          },
          {
            'farmer_name': 'Suresh Pawar',
            'crop_name': 'Grapes',
            'batch_id': '#8821',
            'weight_kg': 750.0,
            'distance_km': 13.8,
            'ton_km': 10.35,
            'payout': 1387.24,
          },
        ],
        'reviews': [
          {
            'author': 'Ramesh Kumar',
            'rating': 5.0,
            'comment': 'Driver arrived exactly on schedule at farm gate. Handled tomato crates very gently.',
            'role': 'Farmer',
            'date': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
          },
          {
            'author': 'Nashik APMC Receiving Supervisor',
            'rating': 4.9,
            'comment': 'Prompt unloading and accurate batch verification with permanent marker IDs matched.',
            'role': 'Buyer / Mandi',
            'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          },
        ],
      };

  Map<String, dynamic> _mockEarnings2() => {
        'id': 'EARN-KS-0090',
        'trip_id': 'TRIP-KS-8840',
        'total_payout': 2400.0,
        'status': 'SETTLED',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
        'destination_name': 'Pimpalgaon Sub-Mandi Hub',
        'duration_min': 70,
        'distance_km': 40.0,
        'vehicle_tier': 'Mahindra Bolero Maxi (Small)',
        'buyer_logistics_fee': 1900.0,
        'farmer_pooled_fee': 700.0,
        'platform_commission': 200.0,
        'ton_km_splits': [
          {
            'farmer_name': 'Vijay More',
            'crop_name': 'Cauliflower',
            'batch_id': '#5210',
            'weight_kg': 800.0,
            'distance_km': 22.0,
            'ton_km': 17.6,
            'payout': 1200.0,
          },
          {
            'farmer_name': 'Anita Shinde',
            'crop_name': 'Green Chillies',
            'batch_id': '#5211',
            'weight_kg': 600.0,
            'distance_km': 18.0,
            'ton_km': 10.8,
            'payout': 1200.0,
          },
        ],
        'reviews': [
          {
            'author': 'Vijay More',
            'rating': 4.8,
            'comment': 'Clean vehicle floor, polite behavior and verified bag weights.',
            'role': 'Farmer',
            'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
        ],
      };

  Map<String, dynamic> _mockEarnings3() => {
        'id': 'EARN-KS-0089',
        'trip_id': 'TRIP-KS-8715',
        'total_payout': 4800.0,
        'status': 'SETTLED',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        'destination_name': 'Dindori Pre-Cooling Export Unit',
        'duration_min': 110,
        'distance_km': 52.5,
        'vehicle_tier': 'Eicher Pro 2049 (Medium)',
        'buyer_logistics_fee': 3800.0,
        'farmer_pooled_fee': 1400.0,
        'platform_commission': 400.0,
        'ton_km_splits': [
          {
            'farmer_name': 'Dattatray Deshmukh',
            'crop_name': 'Export Grapes',
            'batch_id': '#6109',
            'weight_kg': 1200.0,
            'distance_km': 28.5,
            'ton_km': 34.2,
            'payout': 2650.0,
          },
          {
            'farmer_name': 'Subhash Tambe',
            'crop_name': 'Pomegranates',
            'batch_id': '#6110',
            'weight_kg': 950.0,
            'distance_km': 24.0,
            'ton_km': 22.8,
            'payout': 2150.0,
          },
        ],
        'reviews': [
          {
            'author': 'Export Packhouse Manager',
            'rating': 5.0,
            'comment': 'Temperature maintained well and verified QR codes quickly.',
            'role': 'Buyer',
            'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
        ],
      };

  Map<String, dynamic> _mockEarnings4() => {
        'id': 'EARN-KS-0088',
        'trip_id': 'TRIP-KS-8610',
        'total_payout': 1850.0,
        'status': 'SETTLED',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 4))
            .toIso8601String(),
        'destination_name': 'Sinnar Farmer Market Yard',
        'duration_min': 50,
        'distance_km': 27.0,
        'vehicle_tier': 'Tata Ace EV (Small)',
        'buyer_logistics_fee': 1500.0,
        'farmer_pooled_fee': 500.0,
        'platform_commission': 150.0,
        'ton_km_splits': [
          {
            'farmer_name': 'Rajesh Bhoye',
            'crop_name': 'Sweet Corn',
            'batch_id': '#7201',
            'weight_kg': 600.0,
            'distance_km': 15.0,
            'ton_km': 9.0,
            'payout': 950.0,
          },
          {
            'farmer_name': 'Sunita Ahire',
            'crop_name': 'Coriander',
            'batch_id': '#7202',
            'weight_kg': 450.0,
            'distance_km': 12.0,
            'ton_km': 5.4,
            'payout': 900.0,
          },
        ],
        'reviews': [
          {
            'author': 'Sunita Ahire',
            'rating': 4.9,
            'comment': 'Very helpful driver. Loaded coriander bunches without damaging stems.',
            'role': 'Farmer',
            'date': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          },
        ],
      };

  Map<String, dynamic> _mockEarnings5() => {
        'id': 'EARN-KS-0087',
        'trip_id': 'TRIP-KS-8490',
        'total_payout': 5400.0,
        'status': 'SETTLED',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 6))
            .toIso8601String(),
        'destination_name': 'Malegaon Cotton Ginning Mill',
        'duration_min': 140,
        'distance_km': 63.0,
        'vehicle_tier': 'Eicher Pro 10T (Large)',
        'buyer_logistics_fee': 4400.0,
        'farmer_pooled_fee': 1500.0,
        'platform_commission': 500.0,
        'ton_km_splits': [
          {
            'farmer_name': 'Kalyanrao Patil',
            'crop_name': 'Cotton Bales',
            'batch_id': '#8301',
            'weight_kg': 1500.0,
            'distance_km': 35.0,
            'ton_km': 52.5,
            'payout': 3100.0,
          },
          {
            'farmer_name': 'Bapu Wagh',
            'crop_name': 'Soybean Bags',
            'batch_id': '#8302',
            'weight_kg': 1100.0,
            'distance_km': 28.0,
            'ton_km': 30.8,
            'payout': 2300.0,
          },
        ],
        'reviews': [
          {
            'author': 'Ginning Mill Incharge',
            'rating': 4.8,
            'comment': 'High volume load delivered safely, all moisture seals intact.',
            'role': 'Buyer',
            'date': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
          },
        ],
      };
}
