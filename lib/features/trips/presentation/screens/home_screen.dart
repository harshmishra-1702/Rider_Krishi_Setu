// lib/features/trips/presentation/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models.dart';
import '../providers/trip_providers.dart';
import '../widgets/trip_offer_bottom_sheet.dart';
import '../widgets/driver_status_header.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final MapController _mapController = MapController();
  Timer? _countdownTimer;
  int _secondsRemaining = 10;
  bool _isSearching = false;
  bool _showTransparentButton = false;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startOfferDelay() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 10;
      _isSearching = true;
      _showTransparentButton = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      final isOnline = ref.read(isDriverOnlineProvider);
      if (!isOnline) {
        t.cancel();
        if (mounted) setState(() => _isSearching = false);
        return;
      }

      if (_secondsRemaining > 1) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        t.cancel();
        if (mounted) {
          setState(() => _isSearching = false);
          await ref.read(activeTripProvider.notifier).fetchOffer();
          if (mounted && ref.read(activeTripProvider) != null) {
            _showTripOfferSheet(context);
          }
        }
      }
    });
  }

  void _showTripOfferSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TripOfferBottomSheet(),
    ).then((_) {
      // When dismissed or cancelled by driver, display small transparent button to re-simulate
      if (mounted) {
        setState(() => _showTransparentButton = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final strings = ref.watch(appStringsProvider);
    final activeTrip = ref.watch(activeTripProvider);
    final isOnline = ref.watch(isDriverOnlineProvider);
    final locationAsync = ref.watch(locationStreamProvider);

    final driver = authState is AuthAuthenticated ? authState.driver : null;

    // Center map on driver position if stream fires
    locationAsync.whenData((pos) {
      try {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 14.0);
      } catch (_) {}
    });

    final screenHeight = MediaQuery.of(context).size.height;
    // Responsive map height (48% of screen) to prevent pixel overflow on 360x640 screens
    final mapHeight = screenHeight * 0.48;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Map Viewport ──────────────────────────────────────────
          SizedBox(
            height: mapHeight,
            child: _buildMap(locationAsync),
          ),

          // ── Status Header Overlay ─────────────────────────────────
          SafeArea(
            child: DriverStatusHeader(
              driver: driver,
              isOnline: isOnline,
              onlineLabel: strings.online,
              offlineLabel: strings.offline,
              onLanguageTap: () => showLanguageBottomSheet(context, ref),
              onSupportTap: () => context.push('/complaint'),
              onToggleOnline: () {
                final nextOnlineState = !isOnline;
                ref.read(isDriverOnlineProvider.notifier).state = nextOnlineState;
                if (nextOnlineState) {
                  _startOfferDelay();
                } else {
                  _countdownTimer?.cancel();
                  setState(() {
                    _isSearching = false;
                    _showTransparentButton = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You are now Offline. Switch to Online to receive route offers.'),
                      backgroundColor: AppColors.statusOffline,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),

          // ── 10s Countdown Banner (when searching nearby routes) ──
          if (_isSearching && isOnline)
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withOpacity(0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Searching for nearby route offers... ($_secondsRemaining s)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${_secondsRemaining}s',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Small Transparent Re-simulation Button ────────────────
          // (User Request: "if we cancel it, it goes away and display a small transparent button to load the accept ride simulation again")
          if (_showTransparentButton && isOnline && activeTrip != null && activeTrip.status == TripStatus.assigned)
            Positioned(
              top: mapHeight - 52,
              left: 20,
              right: 20,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showTripOfferSheet(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withOpacity(0.7), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.flash_on, color: AppColors.accent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '⚡ Review Available Route Offer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Bottom Info Panel ─────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(context, driver, activeTrip, isOnline, strings),
          ),
        ],
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
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
            selectedIcon:
                Icon(Icons.account_balance_wallet, color: AppColors.primary),
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
              break;
            case 1:
              if (!isOnline) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are Offline. Switch to Online to receive delivery assignments.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              } else if (activeTrip != null) {
                context.push('/route');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No active delivery route right now. Tap "Find Delivery Route" to start.'),
                  ),
                );
              }
              break;
            case 2:
              context.push('/history');
              break;
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

  Widget _buildMap(AsyncValue locationAsync) {
    LatLng center = const LatLng(20.0059, 73.7799); // Nashik default hub

    locationAsync.whenData((pos) {
      if (pos != null) {
        center = LatLng(pos.latitude, pos.longitude);
      }
    });

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.krishisetu.rider_app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 46,
              height: 46,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomPanel(
    BuildContext context,
    Driver? driver,
    RideTrip? activeTrip,
    bool isOnline,
    AppStrings strings,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: (isOnline && activeTrip != null)
          ? _buildActiveTripCard(context, activeTrip, strings)
          : _buildIdleCard(driver, isOnline, strings),
    );
  }

  Widget _buildIdleCard(Driver? driver, bool isOnline, AppStrings strings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.statusOnline.withOpacity(0.12)
                    : AppColors.statusOffline.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color:
                    isOnline ? AppColors.statusOnline : AppColors.statusOffline,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? strings.online : strings.offline,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    isOnline
                        ? 'Waiting for route assignment...'
                        : 'Switch to Online to receive delivery assignments.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (driver != null) ...[
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(
                icon: Icons.star,
                label: '${driver.rating}',
                color: AppColors.accent,
              ),
              _StatChip(
                icon: Icons.local_shipping,
                label: '${driver.totalTrips} trips',
                color: AppColors.primary,
              ),
              _StatChip(
                icon: Icons.scale,
                label: '${(driver.capacityKg / 1000).toStringAsFixed(1)}T',
                color: AppColors.statusInTransit,
              ),
            ],
          ),
        ],
        if (isOnline) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {
                _startOfferDelay();
              },
              icon: const Icon(Icons.radar, size: 18),
              label: const Text('Find Delivery Route (10s Delay)'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveTripCard(BuildContext context, RideTrip trip, AppStrings strings) {
    final isAssigned = trip.status == TripStatus.assigned;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    isAssigned ? Icons.assignment_turned_in : Icons.play_circle,
                    color: AppColors.accent,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isAssigned ? 'New Route Offer' : trip.status.displayLabel,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              '₹${trip.totalTripCost.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          trip.destination.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${trip.waypoints.length} stops • ${trip.distanceKm.toStringAsFixed(1)} km • ~${trip.estimatedDurationMin} min',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        if (isAssigned)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTripOfferSheet(context),
                  icon: const Icon(Icons.assignment, size: 16),
                  label: const Text('Review Offer', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final accepted =
                        await ref.read(activeTripProvider.notifier).acceptTrip();
                    if (accepted && context.mounted) {
                      context.push('/route');
                    }
                  },
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text('Accept & Start', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/route'),
                  icon: const Icon(Icons.navigation, size: 16),
                  label: Text(strings.viewRoutePlan, style: const TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(activeTripProvider.notifier)
                        .markAllPickedUpForDeliveryDemo();
                    context.push('/otp-delivery');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulated all farm pickups done. Ready for Mandi handover!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.fast_forward, color: AppColors.accent, size: 16),
                  label: const Text('⚡ Simulate Delivery Handover (Demo)', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
