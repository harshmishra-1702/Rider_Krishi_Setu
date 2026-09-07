// lib/features/earnings/presentation/widgets/trip_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models.dart';

class TripDetailSheet extends ConsumerWidget {
  final TripEarningsRecord record;

  const TripDetailSheet({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header with Trip ID and Audio button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Audit Log #${record.tripId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${record.vehicleTier} • Settled',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: AppColors.primary),
                tooltip: strings.listenAudio,
                onPressed: () {
                  final msg =
                      'Trip to ${record.destinationName}. Distance: ${record.distanceKm.toStringAsFixed(1)} kilometers, duration: ${record.durationMin} minutes. Net driver payout: ${record.totalPayout.toStringAsFixed(0)} rupees from combined logistics pot.';
                  ttsService.speak(msg, languageCode: selectedLang.ttsLocale);
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Route & Destination Summary ─────────────────────
                  _buildSectionTitle(Icons.place, 'Assigned Delivery Destination'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                record.destinationName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildInfoBadge(
                              Icons.timer_outlined,
                              '~${record.durationMin} mins taken',
                              AppColors.statusInTransit,
                            ),
                            const SizedBox(width: 8),
                            _buildInfoBadge(
                              Icons.route,
                              '${record.distanceKm.toStringAsFixed(1)} km total',
                              AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 2. Combined Logistics Pot Financial Model ───────────
                  _buildSectionTitle(Icons.account_balance, 'Combined Logistics Pot Breakdown'),
                  const SizedBox(height: 4),
                  const Text(
                    'Porter/WheelsEye pooled agri-route model: Buyer fee + Farmer pooled shares form the pot. Platform takes ~8% commission and releases instant driver payout upon delivery confirmation.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  _buildCombinedPotCard(),
                  const SizedBox(height: 18),

                  // ── 3. Farmer Stops & Ton-Km Splitting ─────────────────
                  _buildSectionTitle(Icons.agriculture, 'Farm Pickups & Ton-Km Contributions'),
                  const SizedBox(height: 6),
                  ...record.tonKmContributions.map((split) => _buildFarmerStopCard(split)),
                  const SizedBox(height: 18),

                  // ── 4. Reviews & Ratings ───────────────────────────────
                  _buildSectionTitle(Icons.star, 'Verified Reviews & Ratings'),
                  const SizedBox(height: 6),
                  if (record.reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Center(
                        child: Text(
                          'No written reviews for this run yet.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...record.reviews.map((rev) => _buildReviewCard(rev)),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedPotCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildPotRow('🛒 Buyer Logistics Fee', '₹${record.buyerLogisticsFee.toStringAsFixed(2)}', AppColors.textPrimary),
          const SizedBox(height: 6),
          _buildPotRow('🌾 Farmer Pooled Fee (Ton-Km split)', '₹${record.farmerPooledFee.toStringAsFixed(2)}', AppColors.textPrimary),
          const Divider(height: 14),
          _buildPotRow('💰 Combined Logistics Pot', '₹${record.totalPot.toStringAsFixed(2)}', AppColors.accent, isBold: true),
          const SizedBox(height: 6),
          _buildPotRow('🏢 Platform Commission (~8%)', '-₹${record.platformCommission.toStringAsFixed(2)}', AppColors.danger),
          const Divider(height: 14),
          _buildPotRow('🟢 Net Driver Payout (Escrow Released)', '₹${record.totalPayout.toStringAsFixed(2)}', AppColors.statusDelivered, isBold: true, fontSize: 16),
        ],
      ),
    );
  }

  Widget _buildPotRow(String label, String value, Color valueColor, {bool isBold = false, double fontSize = 13}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmerStopCard(FarmerTonKmContribution split) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      split.farmerName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Bag ${split.batchId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${split.cropName} • ${split.weightKg.toStringAsFixed(0)} kg • ${split.distanceKm.toStringAsFixed(1)} km haul',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  'Ton-Km: ${split.tonKm.toStringAsFixed(2)} T-km',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '₹${split.costShare.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(TripReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.author,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  review.role,
                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 3),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '"${review.comment}"',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
