// lib/features/trips/presentation/screens/route_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/models.dart';
import '../providers/trip_providers.dart';

class RouteScreen extends ConsumerStatefulWidget {
  const RouteScreen({super.key});

  @override
  ConsumerState<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends ConsumerState<RouteScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(activeTripProvider);
    final strings = ref.watch(appStringsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.routePlan)),
        body: const Center(child: Text('No active trip available')),
      );
    }

    final allPickupsCompleted =
        trip.waypoints.isNotEmpty && trip.waypoints.every((w) => w.isPickedUp);

    // Build polyline points: driver/first stop through all waypoints and delivery stops
    final List<LatLng> routePoints = [
      ...trip.waypoints.map((w) => w.latLng),
      ...trip.deliveryStops.map((d) => d.latLng),
      if (trip.deliveryStops.isEmpty) trip.destination.latLng,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(strings.routePlan),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back to Home',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined),
            tooltip: 'Support & Grievance',
            onPressed: () => context.push('/complaint'),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: strings.listenAudio,
            onPressed: () {
              final next = trip.nextWaypoint;
              if (next != null) {
                ttsService.speakStopInstruction(
                  farmerName: next.farmerName,
                  cropName: next.cropName,
                  weightKg: next.weightKg,
                  ttsLocale: selectedLang.ttsLocale,
                );
              } else {
                ttsService.speak(
                  'All farm batches loaded. Proceed to ${trip.destination.name}.',
                  languageCode: selectedLang.ttsLocale,
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.fast_forward),
            tooltip: 'Simulate All Pickups Done',
            onPressed: () {
              ref
                  .read(activeTripProvider.notifier)
                  .markAllPickedUpForDeliveryDemo();
              context.push('/otp-delivery');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulated: Arrived at Bulk Buyer dock with all produce crates!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Map View (top 35%) ─────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: routePoints.first,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.krishisetu.rider_app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.5,
                      color: AppColors.routePolyline,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Farm waypoint markers
                    ...trip.waypoints.map((wp) {
                      final isDone = wp.isPickedUp;
                      return Marker(
                        point: wp.latLng,
                        width: 36,
                        height: 36,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.waypointCompleted
                                : AppColors.waypointPending,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check,
                                    size: 20, color: Colors.white)
                                : Text(
                                    '${wp.stopOrder}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                    // Bulk Buyer Delivery Markers
                    ...trip.deliveryStops.map((ds) {
                      final isDone = ds.isDelivered;
                      return Marker(
                        point: ds.latLng,
                        width: 42,
                        height: 42,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.statusDelivered
                                : const Color(0xFF0C2340),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.done_all,
                                    size: 20, color: Colors.white)
                                : const Icon(Icons.storefront,
                                    size: 20, color: Colors.white),
                          ),
                        ),
                      );
                    }),
                    if (trip.deliveryStops.isEmpty)
                      Marker(
                        point: trip.destination.latLng,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Summary Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${strings.milestones} (${trip.completedPickupsCount}/${trip.waypoints.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Destination: ${trip.destination.name}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '₹${trip.totalTripCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Waypoints Stepper List ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                if (!allPickupsCompleted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: AppColors.accent, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Simulation Mode (Delivery Demo)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Fast-forward all farm pickups to test Bulk Buyer unloading & OTP',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () {
                            ref
                                .read(activeTripProvider.notifier)
                                .markAllPickedUpForDeliveryDemo();
                            context.push('/otp-delivery');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Simulated all farm pickups done! Arrived at Bulk Buyer dock for Handover.'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: const Text('Simulate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ...trip.waypoints.map((wp) => _WaypointCard(
                      waypoint: wp,
                      scanLabel: strings.scanQr,
                      onScan: () {
                        final cleanBatch = wp.batchId.replaceAll('#', '');
                        context.push(
                          '/qr-scanner?stopId=${wp.stopId}&crop=${Uri.encodeComponent(wp.cropName)}&weight=${wp.weightKg}&batchId=$cleanBatch',
                        );
                      },
                      onCall: () async {
                        final uri = Uri.parse('tel:${wp.contactPhone}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      onTts: () {
                        ttsService.speakStopInstruction(
                          farmerName: wp.farmerName,
                          cropName: wp.cropName,
                          weightKg: wp.weightKg,
                          ttsLocale: selectedLang.ttsLocale,
                        );
                      },
                    )),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront, color: Color(0xFF0C2340), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bulk Buyer Delivery Stops (${trip.deliveryStops.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ...trip.deliveryStops.map(
                  (ds) => _DeliveryStopCard(
                    delivery: ds,
                    allPickupsCompleted: allPickupsCompleted,
                    onProceed: () => context.push('/otp-delivery'),
                  ),
                ),
                if (trip.deliveryStops.isEmpty)
                  _DestinationCard(
                    destination: trip.destination,
                    allPickupsCompleted: allPickupsCompleted,
                    proceedLabel: strings.proceedToDelivery,
                    onProceedToDelivery: () {
                      context.push('/otp-delivery');
                    },
                  ),
              ],
            ),
          ),

          // ── Bottom Action Bar ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: allPickupsCompleted
                ? ElevatedButton.icon(
                    onPressed: () => context.push('/otp-delivery'),
                    icon: const Icon(Icons.verified),
                    label: Text(strings.proceedToDelivery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      final next = trip.nextWaypoint;
                      if (next != null) {
                        final cleanBatch = next.batchId.replaceAll('#', '');
                        context.push(
                          '/qr-scanner?stopId=${next.stopId}&crop=${Uri.encodeComponent(next.cropName)}&weight=${next.weightKg}&batchId=$cleanBatch',
                        );
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      '${strings.scanQr} #${trip.nextWaypoint?.stopOrder ?? 1}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _WaypointCard extends StatelessWidget {
  final PickupWaypoint waypoint;
  final VoidCallback onScan;
  final VoidCallback onCall;
  final VoidCallback onTts;
  final String? scanLabel;

  const _WaypointCard({
    required this.waypoint,
    required this.onScan,
    required this.onCall,
    required this.onTts,
    this.scanLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = waypoint.isPickedUp;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDone
              ? AppColors.statusDelivered.withOpacity(0.5)
              : AppColors.cardBorder,
          width: isDone ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.statusDelivered
                        : AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : Text(
                            '${waypoint.stopOrder}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        waypoint.farmerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (waypoint.address != null)
                        Text(
                          waypoint.address!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                // Audio assist button
                IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: AppColors.primary, size: 20),
                  onPressed: onTts,
                ),
                // Call farmer button
                IconButton(
                  icon: const Icon(Icons.phone,
                      color: AppColors.primary, size: 20),
                  onPressed: onCall,
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '🌾 ${waypoint.cropName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⚖️ ${waypoint.weightKg.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                      ),
                      child: Text(
                        '🏷️ Bag ${waypoint.batchId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isDone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statusDelivered.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '✓ Picked Up',
                      style: TextStyle(
                        color: AppColors.statusDelivered,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    onPressed: onScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(110, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: Text(scanLabel ?? 'Scan QR'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final DropoffLocation destination;
  final bool allPickupsCompleted;
  final VoidCallback onProceedToDelivery;
  final String? proceedLabel;

  const _DestinationCard({
    required this.destination,
    required this.allPickupsCompleted,
    required this.onProceedToDelivery,
    this.proceedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24, top: 4),
      color: allPickupsCompleted
          ? AppColors.primary.withOpacity(0.06)
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: allPickupsCompleted ? AppColors.primary : AppColors.cardBorder,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warehouse,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bulk Buyer Delivery Hub',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        destination.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              destination.address,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            if (allPickupsCompleted) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onProceedToDelivery,
                icon: const Icon(Icons.location_on),
                label: Text(proceedLabel ?? 'Start Geofenced Delivery Check'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeliveryStopCard extends StatelessWidget {
  final DeliveryWaypoint delivery;
  final bool allPickupsCompleted;
  final VoidCallback onProceed;

  const _DeliveryStopCard({
    required this.delivery,
    required this.allPickupsCompleted,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = delivery.isDelivered;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isDone
          ? AppColors.statusDelivered.withOpacity(0.06)
          : (allPickupsCompleted ? AppColors.primary.withOpacity(0.04) : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDone
              ? AppColors.statusDelivered
              : (allPickupsCompleted ? AppColors.primary : AppColors.cardBorder),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.statusDelivered : const Color(0xFF0C2340),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.storefront,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C2340).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              delivery.buyerType,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0C2340),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Stop #${delivery.stopOrder}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        delivery.buyerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${delivery.cropName} • ${delivery.weightKg.toStringAsFixed(0)} kg (Batch ID: ${delivery.batchId})',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              delivery.address,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (allPickupsCompleted && !isDone) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onProceed,
                  icon: const Icon(Icons.verified, size: 18),
                  label: Text('Verify ${delivery.buyerName.split(',').first} Handover OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
