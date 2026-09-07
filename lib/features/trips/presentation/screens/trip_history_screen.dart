// lib/features/trips/presentation/screens/trip_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../earnings/domain/models.dart';
import '../../../earnings/presentation/providers/earnings_providers.dart';
import '../../../earnings/presentation/widgets/trip_detail_sheet.dart';
import '../providers/trip_providers.dart';

class TripHistoryScreen extends ConsumerStatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(earningsHistoryProvider);
    final strings = ref.watch(appStringsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final ttsService = ref.watch(ttsServiceProvider);
    final activeTrip = ref.watch(activeTripProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ride & Trip History'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Listen History Summary',
            onPressed: () {
              historyAsync.whenData((trips) {
                final total = trips.fold<double>(0, (sum, t) => sum + t.totalPayout);
                final msg =
                    'You have completed ${trips.length} delivery routes with total earnings of ${total.toStringAsFixed(0)} rupees. Tap any trip to hear detailed farm logs, payment pot breakdown, and reviews.';
                ttsService.speak(msg, languageCode: selectedLang.ttsLocale);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(earningsHistoryProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(earningsHistoryProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Lifetime Statistics Card ────────────────────────────────
            _buildLifetimeSummaryCard(context, ref),
            const SizedBox(height: 18),

            // ── Section Header & Filter Chips ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Completed Delivery Runs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Tap for Audit Log',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildFilterChips(),
            const SizedBox(height: 14),

            // ── Trip History List ───────────────────────────────────────
            historyAsync.when(
              data: (trips) {
                final filtered = _filterTrips(trips);
                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      children: const [
                        Icon(Icons.history_toggle_off, size: 48, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'No trips matching this filter',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: filtered
                      .map((record) => _buildTripHistoryCard(context, record, strings))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Failed to load history: $err'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.route_outlined),
            selectedIcon: const Icon(Icons.route, color: AppColors.primary),
            label: strings.routePlan,
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: 'History',
          ),
          const NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
            label: 'Earnings',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              if (activeTrip != null) {
                context.push('/route');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No active delivery route right now.')),
                );
              }
              break;
            case 2:
              break; // already on history
            case 3:
              context.push('/earnings');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildLifetimeSummaryCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Driver Career Summary',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: AppColors.accentLight, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Verified Partner',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('34', 'Completed Trips', Icons.local_shipping),
              _buildStatItem('₹74,500', 'Total Earned', Icons.currency_rupee),
              _buildStatItem('4.8 ★', 'Rider Rating', Icons.star),
              _buildStatItem('1,240', 'Ton-Km Haul', Icons.scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentLight, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'ALL', 'label': 'All Trips'},
      {'key': 'RECENT', 'label': 'Recent'},
      {'key': 'HIGH_VALUE', 'label': 'High Payout (₹3k+)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(f['label']!),
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (_) {
                setState(() => _selectedFilter = f['key']!);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  List<TripEarningsRecord> _filterTrips(List<TripEarningsRecord> trips) {
    if (_selectedFilter == 'HIGH_VALUE') {
      return trips.where((t) => t.totalPayout >= 3000).toList();
    }
    if (_selectedFilter == 'RECENT') {
      return trips.take(3).toList();
    }
    return trips;
  }

  Widget _buildTripHistoryCard(
    BuildContext context,
    TripEarningsRecord record,
    AppStrings strings,
  ) {
    final dateStr = '${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}';
    final farmersCount = record.tonKmContributions.length;
    final avgRating = record.reviews.isNotEmpty
        ? (record.reviews.fold<double>(0, (acc, r) => acc + r.rating) / record.reviews.length).toStringAsFixed(1)
        : '4.9';

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TripDetailSheet(record: record),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Trip ID, Vehicle Tier, Settled Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${record.tripId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  record.vehicleTier,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.statusDelivered.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, size: 12, color: AppColors.statusDelivered),
                      SizedBox(width: 4),
                      Text(
                        'Settled & Paid',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusDelivered,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Destination and Payout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.destinationName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$farmersCount Farm Gate Pickups • $dateStr',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${record.totalPayout.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Metrics chips (Distance, Duration, Rating, Combined Pot)
            Row(
              children: [
                _buildSmallChip(Icons.straighten, '${record.distanceKm.toStringAsFixed(1)} km'),
                const SizedBox(width: 8),
                _buildSmallChip(Icons.timer_outlined, '~${record.durationMin} mins'),
                const SizedBox(width: 8),
                _buildSmallChip(Icons.star, '$avgRating ★', color: AppColors.accent),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => TripDetailSheet(record: record),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 14),
                  label: const Text('Audit Log', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallChip(IconData icon, String text, {Color? color}) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
