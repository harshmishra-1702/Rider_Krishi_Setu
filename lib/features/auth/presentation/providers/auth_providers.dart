// lib/features/auth/presentation/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/models.dart';

// ── Language provider ──────────────────────────────────────────────────────
final selectedLanguageProvider =
    StateNotifierProvider<SelectedLanguageNotifier, AppLanguage>(
  (ref) => SelectedLanguageNotifier(ref.watch(authRepositoryProvider)),
);

class SelectedLanguageNotifier extends StateNotifier<AppLanguage> {
  final AuthRepository _repo;

  SelectedLanguageNotifier(this._repo) : super(AppLanguage.supported.first) {
    _load();
  }

  Future<void> _load() async {
    final code = await _repo.getSavedLanguage();
    if (code != null) {
      state = AppLanguage.supported.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.supported.first,
      );
    }
  }

  Future<void> select(AppLanguage language) async {
    state = language;
    await _repo.saveLanguage(language.code);
  }
}

// ── Auth state notifier ────────────────────────────────────────────────────
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>(
  (ref) => AuthStateNotifier(ref.watch(authRepositoryProvider)),
);

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  String? _pendingPhone;

  static const Set<String> registeredPhones = {
    '9876543210', // Suresh Yadav (Tata Ace Gold)
    '9822334455', // Sanjay Shinde (Eicher Pro 10T Reefer)
    '9922114433', // Baburao Kadam (Mahindra Treo Zor Micro)
  };

  static bool isPhoneRegistered(String phone) {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final last10 = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;
    return registeredPhones.contains(last10);
  }

  AuthStateNotifier(this._repo) : super(const AuthInitial());

  Future<void> sendOtp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final last10 = clean.length >= 10 ? clean.substring(clean.length - 10) : clean;

    if (!registeredPhones.contains(last10)) {
      state = AuthUnregistered(
        last10,
        'Mobile number +91 $last10 is not registered as a KrishiSetu Driver Partner. Please register to onboard your vehicle.',
      );
      return;
    }

    state = const AuthLoading();
    try {
      await _repo.sendOtp(last10);
      _pendingPhone = last10;
      state = AuthOtpSent(last10);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_pendingPhone == null) return;
    state = const AuthLoading();
    try {
      final result =
          await _repo.verifyOtp(phone: _pendingPhone!, otp: otp);
      if (result.isNewUser) {
        state = AuthNeedsProfile(result.driverId, result.token);
      } else {
        final driver = await _repo.getDriverProfile();
        if (driver != null) {
          state = AuthAuthenticated(driver);
        } else {
          state = AuthNeedsProfile(result.driverId, result.token);
        }
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> saveProfile({
    required String name,
    required String licenseNumber,
    required VehicleTier vehicleTier,
    required String vehicleNumber,
    required String vehicleModel,
    String? upiId,
  }) async {
    state = const AuthLoading();
    try {
      final driver = await _repo.updateDriverProfile(
        name: name,
        licenseNumber: licenseNumber,
        vehicleTier: vehicleTier,
        vehicleNumber: vehicleNumber,
        vehicleModel: vehicleModel,
        upiId: upiId,
      );
      state = AuthAuthenticated(driver);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthInitial();
  }

  void resetError() {
    state = const AuthInitial();
  }
}
