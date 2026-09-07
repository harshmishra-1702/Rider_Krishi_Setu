// lib/features/earnings/presentation/screens/earnings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../../../auth/domain/models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../trips/presentation/providers/trip_providers.dart';
import '../../domain/models.dart';
import '../providers/earnings_providers.dart';
import '../widgets/trip_detail_sheet.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(walletProvider);
    final historyAsync = ref.watch(earningsHistoryProvider);
    final activeTrip = ref.watch(activeTripProvider);
    final authState = ref.watch(authStateProvider);
    final strings = ref.watch(appStringsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final ttsService = ref.watch(ttsServiceProvider);
    final driver = authState is AuthAuthenticated ? authState.driver : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(strings.escrowBalance),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: strings.listenAudio,
            onPressed: () {
              walletAsync.whenData((wallet) {
                final msg =
                    '${strings.escrowBalance}: ${wallet.availableBalance.toStringAsFixed(0)} rupees. ${wallet.inEscrowPending.toStringAsFixed(0)} rupees in escrow.';
                ttsService.speak(msg, languageCode: selectedLang.ttsLocale);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(walletProvider);
              ref.invalidate(earningsHistoryProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(earningsHistoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Escrow Wallet Card ────────────────────────────────────
            walletAsync.when(
              data: (wallet) => _buildWalletCard(context, ref, wallet, driver?.upiId, strings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Error loading wallet: $err'),
              ),
            ),
            const SizedBox(height: 20),

            // ── Ton-Km Cost Splitting Formula Banner ─────────────────
            _buildTonKmFormulaBanner(context, strings),
            const SizedBox(height: 20),

            // ── Current / Recent Completed Trip Breakdown ─────────────
            if (activeTrip != null && activeTrip.tonKmSplits.isNotEmpty) ...[
              Text(
                'Current Trip Ton-Km Split',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Each farmer pays proportionally based on load weight × haul distance',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildCurrentTripSplitCard(activeTrip),
              const SizedBox(height: 24),
            ],

            // ── Payout History ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settled Payouts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => context.push('/history'),
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View All History →'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            historyAsync.when(
              data: (history) => Column(
                children: history.map((rec) => _buildHistoryCard(context, rec)).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Failed to load history: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    WidgetRef ref,
    EscrowWallet wallet,
    String? upiId,
    AppStrings strings,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.escrowBalance,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_clock, color: AppColors.accentLight, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Smart Escrow Secured',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹ ${wallet.availableBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'In Escrow (Pending Delivery): ₹ ${wallet.inEscrowPending.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showWithdrawDialog(
              context,
              ref,
              wallet.availableBalance,
              upiId ?? 'suresh.yadav@upi',
            ),
            icon: const Icon(Icons.flash_on, color: AppColors.textPrimary),
            label: Text(strings.instantWithdraw),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonKmFormulaBanner(BuildContext context, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Combined Logistics Pot & Ton-Km Model',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Combined Pot = Buyer Fee + ∑ Farmer Pooled Share',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Farmer Share (Fi) = L_farmers × (Wi × Di) / ∑(Wj × Dj)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Driver Payout = Combined Pot − Platform Fee (~8%)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.statusDelivered,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Built-in transaction model (Porter/WheelsEye/Dunzo style). Zero out-of-pocket extra costs; driver is paid immediately from the escrow pot upon delivery confirmation.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTripSplitCard(dynamic trip) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...trip.tonKmSplits.map<Widget>((split) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              split.farmerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${split.weightKg.toStringAsFixed(0)} kg • ${split.distanceKm.toStringAsFixed(1)} km (${split.tonKm.toStringAsFixed(2)} Ton-Km)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${split.payout.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Trip Payout',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  '₹${trip.totalTripCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, TripEarningsRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => FractionallySizedBox(
              heightFactor: 0.88,
              child: TripDetailSheet(record: record),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status and Payout
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.statusDelivered.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.statusDelivered,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Trip #${record.tripId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${record.totalPayout.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Destination & Duration
              Row(
                children: [
                  const Icon(Icons.storefront, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.destinationName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '~${record.durationMin} mins • ${record.distanceKm.toStringAsFixed(1)} km • ${record.vehicleTier}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Chips: Pot split + Review rating
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Pot: ₹${record.totalPot.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (record.reviews.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            '${record.reviews.first.rating.toStringAsFixed(1)} (${record.reviews.length} reviews)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB78103),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${record.tonKmContributions.length} Farm Pickups',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),

              // Click action hint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Tap to view audit log & reviews',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawDialog(
    BuildContext context,
    WidgetRef ref,
    double balance,
    String defaultUpi,
  ) {
    final upiCtrl = TextEditingController(text: defaultUpi);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Instant UPI Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transferable balance: ₹${balance.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: upiCtrl,
              decoration: const InputDecoration(
                labelText: 'UPI VPA Address',
                hintText: 'e.g. mobile@upi',
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Funds are disbursed instantly from the KrishiSetu Escrow pool to your verified bank account.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await ref
                  .read(payoutProvider.notifier)
                  .withdraw(amount: balance, upiId: upiCtrl.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Payout initiated! ₹${balance.toStringAsFixed(0)} will arrive in your UPI account.'
                          : 'Withdrawal failed. Please try again.',
                    ),
                    backgroundColor:
                        ok ? AppColors.statusDelivered : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Withdraw Now'),
          ),
        ],
      ),
    );
  }
}
