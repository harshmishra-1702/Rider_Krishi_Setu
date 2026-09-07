// lib/features/auth/presentation/screens/language_select_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../providers/auth_providers.dart';

class LanguageSelectScreen extends ConsumerWidget {
  final bool fromSettings;

  const LanguageSelectScreen({super.key, this.fromSettings = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final strings = ref.watch(appStringsProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            if (fromSettings || context.canPop()) {
              context.pop();
            } else {
              context.go('/otp');
            }
          },
        ),
        title: fromSettings
            ? const Text(
                'Change Language',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            tooltip: strings.listenAudio,
            onPressed: () {
              // ON-CLICK ONLY: Speaks in currently chosen regional language
              String msg;
              switch (selectedLanguage.code) {
                case 'hi':
                  msg = 'कृपया अपनी पसंदीदा भाषा चुनें और आगे बढ़ें।';
                  break;
                case 'mr':
                  msg = 'कृपया आपली भाषा निवडा आणि पुढे जा.';
                  break;
                case 'ta':
                  msg = 'தங்களுக்கு விருப்பமான மொழியைத் தேர்ந்தெடுத்து தொடரவும்.';
                  break;
                case 'te':
                  msg = 'దయచేసి మీకు నచ్చిన భాషను ఎంచుకుని కొనసాగించండి.';
                  break;
                case 'kn':
                  msg = 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ ಮತ್ತು ಮುಂದುವರಿಯಿರಿ.';
                  break;
                default:
                  msg = 'Please choose your preferred language and continue.';
                  break;
              }
              ttsService.speak(msg, languageCode: selectedLanguage.ttsLocale);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!fromSettings) ...[
              _buildHeader(),
              const SizedBox(height: 14),
            ],
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        strings.selectLanguage,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.selectLanguageSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      // Responsive Grid of 6 Languages
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: AppLanguage.supported.length,
                        itemBuilder: (context, index) {
                          final lang = AppLanguage.supported[index];
                          final isSelected = lang.code == selectedLanguage.code;
                          return _LanguageCard(
                            language: lang,
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(selectedLanguageProvider.notifier).select(lang);
                            },
                            onAudioTap: () {
                              // Plays sound for this specific regional language
                              ttsService.speakLanguageGreeting(lang.code);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (fromSettings || context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/otp');
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                fromSettings
                                    ? 'Save & Apply Language'
                                    : '${strings.continueBtn} to Login',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                fromSettings ? Icons.check : Icons.arrow_forward,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'KrishiSetu',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
            letterSpacing: 0.5,
          ),
        ),
        const Text(
          'Rural Logistics & Delivery Partner',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAudioTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    language.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.85)
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 16),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: onAudioTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.volume_up,
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
