// lib/core/widgets/language_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_strings.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../../features/auth/domain/models.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

void showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _LanguageModalContent(),
  );
}

class _LanguageModalContent extends ConsumerWidget {
  const _LanguageModalContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final strings = ref.watch(appStringsProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.language, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.selectLanguage,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      strings.selectLanguageSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 6 Language Cards in 2 columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: AppLanguage.supported.length,
            itemBuilder: (ctx, i) {
              final lang = AppLanguage.supported[i];
              final isSelected = lang.code == selectedLanguage.code;

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  // Change language immediately
                  await ref.read(selectedLanguageProvider.notifier).select(lang);
                  // Play audio greeting for feedback
                  ttsService.speakLanguageGreeting(lang.code);
                  // Close modal sheet - user stays on the EXACT SAME PAGE
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.12)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang.nativeName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              lang.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.85)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary, size: 18)
                      else
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18, color: AppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: () {
                            ttsService.speakLanguageGreeting(lang.code);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
