// lib/features/auth/domain/models.dart
import 'package:flutter/material.dart';

enum VehicleTier {
  micro(
    label: 'Micro',
    subtitle: 'E-Rickshaw / Auto-Cart',
    capacityKg: 250,
    icon: Icons.electric_rickshaw,
    color: Color(0xFF00695C),
  ),
  small(
    label: 'Small',
    subtitle: 'Tata Ace / Bolero Maxi',
    capacityKg: 1500,
    icon: Icons.local_shipping,
    color: Color(0xFF1B5E20),
  ),
  medium(
    label: 'Medium',
    subtitle: 'Dost / Eicher Pro',
    capacityKg: 5000,
    icon: Icons.fire_truck,
    color: Color(0xFFE65100),
  ),
  large(
    label: 'Large',
    subtitle: 'Heavy Commercial / Reefer',
    capacityKg: 10000,
    icon: Icons.directions_bus,
    color: Color(0xFF37474F),
  );

  const VehicleTier({
    required this.label,
    required this.subtitle,
    required this.capacityKg,
    required this.icon,
    required this.color,
  });

  final String label;
  final String subtitle;
  final int capacityKg;
  final IconData icon;
  final Color color;

  String get capacityDisplay {
    if (capacityKg >= 1000) {
      return '${(capacityKg / 1000).toStringAsFixed(1)}T';
    }
    return '${capacityKg}kg';
  }

  static VehicleTier fromString(String value) {
    return VehicleTier.values.firstWhere(
      (t) => t.name.toUpperCase() == value.toUpperCase(),
      orElse: () => VehicleTier.small,
    );
  }
}

class Driver {
  final String driverId;
  final String name;
  final String phone;
  final String aadhaar; // Always '[Aadhaar Redacted]'
  final String licenseNumber;
  final VehicleTier vehicleTier;
  final String vehicleNumber;
  final String vehicleModel;
  final double capacityKg;
  final double rating;
  final int totalTrips;
  final String? profilePhotoUrl;
  final String? upiId;
  final bool isOnline;

  const Driver({
    required this.driverId,
    required this.name,
    required this.phone,
    this.aadhaar = '[Aadhaar Redacted]',
    required this.licenseNumber,
    required this.vehicleTier,
    required this.vehicleNumber,
    required this.vehicleModel,
    required this.capacityKg,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.profilePhotoUrl,
    this.upiId,
    this.isOnline = false,
  });

  Driver copyWith({
    String? driverId,
    String? name,
    String? phone,
    String? licenseNumber,
    VehicleTier? vehicleTier,
    String? vehicleNumber,
    String? vehicleModel,
    double? capacityKg,
    double? rating,
    int? totalTrips,
    String? profilePhotoUrl,
    String? upiId,
    bool? isOnline,
  }) {
    return Driver(
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      aadhaar: '[Aadhaar Redacted]',
      licenseNumber: licenseNumber ?? this.licenseNumber,
      vehicleTier: vehicleTier ?? this.vehicleTier,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      capacityKg: capacityKg ?? this.capacityKg,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      upiId: upiId ?? this.upiId,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        driverId: json['driver_id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        aadhaar: '[Aadhaar Redacted]',
        licenseNumber: json['license_number'] as String? ?? '',
        vehicleTier:
            VehicleTier.fromString(json['vehicle_tier'] as String? ?? 'SMALL'),
        vehicleNumber: json['vehicle_number'] as String? ?? '',
        vehicleModel: json['vehicle_model'] as String? ?? '',
        capacityKg: (json['capacity_kg'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        totalTrips: json['total_trips'] as int? ?? 0,
        profilePhotoUrl: json['profile_photo'] as String?,
        upiId: json['upi_id'] as String?,
        isOnline: json['is_online'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'driver_id': driverId,
        'name': name,
        'phone': phone,
        'aadhaar': '[Aadhaar Redacted]',
        'license_number': licenseNumber,
        'vehicle_tier': vehicleTier.name.toUpperCase(),
        'vehicle_number': vehicleNumber,
        'vehicle_model': vehicleModel,
        'capacity_kg': capacityKg,
        'rating': rating,
        'total_trips': totalTrips,
        'profile_photo': profilePhotoUrl,
        'upi_id': upiId,
        'is_online': isOnline,
      };
}

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String ttsLocale;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.ttsLocale,
  });

  static const List<AppLanguage> supported = [
    AppLanguage(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        ttsLocale: 'en-IN'),
    AppLanguage(
        code: 'hi',
        name: 'Hindi',
        nativeName: 'हिन्दी',
        ttsLocale: 'hi-IN'),
    AppLanguage(
        code: 'mr',
        name: 'Marathi',
        nativeName: 'मराठी',
        ttsLocale: 'mr-IN'),
    AppLanguage(
        code: 'ta',
        name: 'Tamil',
        nativeName: 'தமிழ்',
        ttsLocale: 'ta-IN'),
    AppLanguage(
        code: 'te',
        name: 'Telugu',
        nativeName: 'తెలుగు',
        ttsLocale: 'te-IN'),
    AppLanguage(
        code: 'kn',
        name: 'Kannada',
        nativeName: 'ಕನ್ನಡ',
        ttsLocale: 'kn-IN'),
  ];
}

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final String phone;
  const AuthOtpSent(this.phone);
}

class AuthAuthenticated extends AuthState {
  final Driver driver;
  const AuthAuthenticated(this.driver);
}

class AuthNeedsProfile extends AuthState {
  final String driverId;
  final String token;
  const AuthNeedsProfile(this.driverId, this.token);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthUnregistered extends AuthState {
  final String phone;
  final String message;
  const AuthUnregistered(this.phone, this.message);
}
