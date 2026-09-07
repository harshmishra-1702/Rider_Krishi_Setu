import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_constants.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/trip_providers.dart';

class TripOfferBottomSheet extends ConsumerStatefulWidget {
  const TripOfferBottomSheet({super.key});

  @override
  ConsumerState<TripOfferBottomSheet> createState() =>
      _TripOfferBottomSheetState();
}

class _TripOfferBottomSheetState extends ConsumerState<TripOfferBottomSheet> {
  int _countdown = AppConstants.tripOfferTimeoutSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _countdown--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(activeTripProvider);
    final strings = ref.watch(appStringsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    if (trip == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.cvrpRunAssigned,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.destination.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.primary),
                tooltip: strings.listenAudio,
                onPressed: () {
                  final msg =
                      '${strings.cvrpRunAssigned}. ${trip.destination.name}. ${trip.waypoints.length} stops. ${strings.guaranteedPayout} ${trip.totalTripCost.toStringAsFixed(0)} rupees.';
                  ttsService.speak(msg, languageCode: selectedLang.ttsLocale);
                },
              ),
              const SizedBox(width: 4),
              // Countdown ring
              SizedBox(
                width: 50,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _countdown / AppConstants.tripOfferTimeoutSeconds,
                      backgroundColor: AppColors.cardBorder,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.accent),
                      strokeWidth: 4,
                    ),
                    Text(
                      '$_countdown',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Trip info pills
          Row(
            children: [
              _InfoPill(
                icon: Icons.scale,
                label: '${(trip.totalWeightKg / 1000).toStringAsFixed(1)}T load',
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.location_on,
                label: '${trip.waypoints.length} stops',
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.timer,
                label: '${trip.estimatedDurationMin}min',
                color: AppColors.statusInTransit,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Payout highlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.guaranteedPayout,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₹ ${trip.totalTripCost.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${trip.distanceKm.toStringAsFixed(0)} km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Accept / Reject buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    _timer?.cancel();
                    await ref.read(activeTripProvider.notifier).rejectTrip();
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 2),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    _timer?.cancel();
                    final accepted =
                        await ref.read(activeTripProvider.notifier).acceptTrip();
                    if (context.mounted) {
                      Navigator.pop(context);
                      if (accepted) context.go('/route');
                    }
                  },
                  child: const Text('Accept Trip'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
