// lib/features/auth/presentation/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/user_role.dart';
import '../providers/auth_providers.dart';

final selectedRoleProvider = StateProvider<UserRole>((ref) => UserRole.rider);

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedRoleProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final strings = ref.watch(appStringsProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(strings.selectRoleTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Language',
            onPressed: () => context.push('/language?from=settings'),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: strings.listenAudio,
            onPressed: () {
              // ON-CLICK ONLY TTS
              final msg = selectedLang.code == 'hi'
                  ? 'कृषिसेतु में अपनी भूमिका चुनें: उपभोक्ता, थोक खरीदार, किसान, या राइडर।'
                  : selectedLang.code == 'mr'
                      ? 'कृषीसेतूमध्ये आपली भूमिका निवडा: ग्राहक, व्यापारी, शेतकरी, किंवा रायडर.'
                      : 'Choose your portal in KrishiSetu: Consumer, Bulk Buyer, Farmer, or Logistics Rider.';
              ttsService.speak(msg, languageCode: selectedLang.ttsLocale);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header banner with official logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.selectRoleTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          strings.selectRoleSubtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Role selection cards list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: UserRole.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final role = UserRole.values[index];
                  final isSelected = role == selectedRole;

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedRoleProvider.notifier).state = role;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? role.color.withOpacity(0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? role.color : AppColors.cardBorder,
                          width: isSelected ? 2.2 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: role.color.withOpacity(0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? role.color
                                  : role.color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              role.icon,
                              color: isSelected ? Colors.white : role.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        role.localizedTitle(selectedLang.code),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? role.color
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (role == UserRole.rider)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Text(
                                          'ACTIVE APP',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  role.localizedSubtitle(selectedLang.code),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Radio<UserRole>(
                            value: role,
                            groupValue: selectedRole,
                            activeColor: role.color,
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(selectedRoleProvider.notifier).state =
                                    val;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Continue action
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.cardBorder)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedRole == UserRole.rider) {
                      context.push('/language');
                    } else {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(selectedRole.localizedTitle(selectedLang.code)),
                          content: Text(
                            'You selected "${selectedRole.title}". The KrishiSetu Rider application is currently operating as the logistics transport execution app for this portal. Proceed to driver verification & delivery dispatches.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Back'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.push('/language');
                              },
                              child: const Text('Proceed to Rider Portal'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${strings.continueAs} ${selectedRole.localizedTitle(selectedLang.code)}'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
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
}
