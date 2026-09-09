// lib/features/auth/presentation/screens/otp_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../providers/auth_providers.dart';
import '../../domain/models.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  bool _otpSent = false;
  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown <= 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  String get _otpValue =>
      _otpControllers.map((c) => c.text).join();

  void _showUnregisteredDialog(String phone, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.person_off, color: AppColors.accent, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Driver Not Registered', style: TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Only verified logistics partners can log in. If you are a new driver, click below to complete your vehicle profile and Aadhaar onboarding.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Try Another Number'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/vehicle-profile');
            },
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('Register Here'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final strings = ref.watch(appStringsProvider);

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next is AuthOtpSent) {
        setState(() => _otpSent = true);
        _startResendTimer();
      } else if (next is AuthUnregistered) {
        _showUnregisteredDialog(next.phone, next.message);
      } else if (next is AuthAuthenticated) {
        context.go('/home');
      } else if (next is AuthNeedsProfile) {
        context.go('/vehicle-profile');
      } else if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _otpSent
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                onPressed: () => setState(() => _otpSent = false),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.primary),
            tooltip: 'Change Language (Stays on this page)',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            tooltip: 'Voice Help',
            onPressed: () {
              final lang = ref.read(selectedLanguageProvider);
              final msg = _otpSent
                  ? (lang.code == 'hi'
                      ? 'कृपया 4 अंकों का सत्यापन कोड दर्ज करें।'
                      : 'Please enter the 4-digit verification code.')
                  : (lang.code == 'hi'
                      ? 'कृपया अपना पंजीकृत 10 अंकों का मोबाइल नंबर दर्ज करें और ओटीपी भेजें।'
                      : 'Please enter your registered 10-digit mobile number and send OTP.');
              ref
                  .read(ttsServiceProvider)
                  .speak(msg, languageCode: lang.ttsLocale);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'KrishiSetu Partner',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Driver Authentication Desk',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _otpSent ? strings.enterOtp : strings.loginTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              _otpSent
                  ? 'OTP sent to +91 ${_phoneController.text}'
                  : strings.loginSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
            ),
            const SizedBox(height: 24),
            if (!_otpSent) ...[
              _buildPhoneField(strings),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_phoneController.text.length == 10) {
                            ref
                                .read(authStateProvider.notifier)
                                .sendOtp(_phoneController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(strings.sendOtp, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              // Registration Card (User Request: "click here to register if not yet registered")
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add_alt_1, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'New Driver Partner?',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Not registered yet? Click here to Register & onboard vehicle.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/vehicle-profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(76, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Register', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildOtpFields(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading || _otpValue.length < 4
                      ? null
                      : () => ref
                          .read(authStateProvider.notifier)
                          .verifyOtp(_otpValue),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(strings.verifyLogin, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _resendCountdown > 0
                    ? Text(
                        'Resend OTP in ${_resendCountdown}s',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14),
                      )
                    : TextButton(
                        onPressed: () => ref
                            .read(authStateProvider.notifier)
                            .sendOtp(_phoneController.text),
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    for (int i = 0; i < 4; i++) {
                      _otpControllers[i].text = '1234'[i];
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.key, size: 16),
                  label: const Text('Auto-fill Test OTP (1234)'),
                ),
              ),
            ],
            const SizedBox(height: 32),
            Center(
              child: Text(
                '🔒 Encrypted Rural Logistics Platform • KrishiSetu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField(AppStrings strings) {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: strings.mobileNumber,
        hintText: '9876543210',
        prefixText: '+91  ',
        prefixStyle: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        counterText: '',
        suffixIcon: const Icon(Icons.phone, color: AppColors.primary),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 64,
          height: 68,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.cardBorder, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2.5),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
            onChanged: (val) {
              if (val.length == 1 && index < 3) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (val.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }
}
