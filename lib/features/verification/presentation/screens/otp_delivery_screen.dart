// lib/features/verification/presentation/screens/otp_delivery_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../trips/domain/models.dart';
import '../../../trips/presentation/providers/trip_providers.dart';
import '../providers/verification_providers.dart';

class OtpDeliveryScreen extends ConsumerStatefulWidget {
  const OtpDeliveryScreen({super.key});

  @override
  ConsumerState<OtpDeliveryScreen> createState() => _OtpDeliveryScreenState();
}

class _OtpDeliveryScreenState extends ConsumerState<OtpDeliveryScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  int _selectedStopIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final trip = ref.read(activeTripProvider);
      if (trip != null) {
        if (trip.deliveryStops.isNotEmpty) {
          final firstPending =
              trip.deliveryStops.indexWhere((s) => !s.isDelivered);
          if (firstPending != -1) {
            setState(() => _selectedStopIndex = firstPending);
          }
        }
        _checkGeofenceForCurrentStop(trip);
      }
    });
  }

  void _checkGeofenceForCurrentStop(RideTrip trip) {
    if (trip.deliveryStops.isNotEmpty &&
        _selectedStopIndex < trip.deliveryStops.length) {
      final stop = trip.deliveryStops[_selectedStopIndex];
      ref.read(deliveryProvider.notifier).checkGeofence(
            DropoffLocation(
              name: stop.buyerName,
              address: stop.address,
              latitude: stop.latitude,
              longitude: stop.longitude,
            ),
          );
    } else {
      ref.read(deliveryProvider.notifier).checkGeofence(trip.destination);
    }
  }

  void _clearOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
    if (_otpFocusNodes.isNotEmpty) {
      _otpFocusNodes.first.requestFocus();
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _showManualBatchDialog(RideTrip trip) {
    final unverified =
        trip.waypoints.where((w) => !w.isDeliveryVerified).toList();
    final defaultCode =
        unverified.isNotEmpty ? unverified.first.batchId.replaceAll('#', '') : '4092';
    final ctrl = TextEditingController(text: defaultCode);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.edit_note, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Manual Batch Entry'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the 4-digit code written with permanent marker on the bag to verify handover:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                prefixText: '#',
                labelText: 'Bag Batch ID',
                hintText: '4092',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (unverified.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: unverified
                    .map((w) => ActionChip(
                          label: Text(w.batchId, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            ctrl.text = w.batchId.replaceAll('#', '');
                          },
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                final matched = ref
                    .read(activeTripProvider.notifier)
                    .verifyDeliveryBatch(val);
                Navigator.pop(ctx);
                if (matched) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Verified Bag #$val for unloading.'),
                      backgroundColor: AppColors.statusDelivered,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No package found matching #$val in this trip.'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Verify Bag'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(activeTripProvider);
    final strings = ref.watch(appStringsProvider);
    final deliveryState = ref.watch(deliveryProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.proceedToDelivery)),
        body: const Center(child: Text('No active trip')),
      );
    }

    final hasMultipleStops = trip.deliveryStops.isNotEmpty;
    final currentDeliveryStop = hasMultipleStops &&
            _selectedStopIndex < trip.deliveryStops.length
        ? trip.deliveryStops[_selectedStopIndex]
        : null;

    final isCurrentStopDelivered = currentDeliveryStop?.isDelivered ?? false;
    final allBagsVerified = trip.allDeliveriesVerified;
    final photoAttached = deliveryState.capturedPhotoPath != null;
    final canEnterOtp =
        (!isCurrentStopDelivered) && (allBagsVerified && photoAttached);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(strings.proceedToDelivery),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back',
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
            icon: const Icon(Icons.volume_up),
            tooltip: strings.listenAudio,
            onPressed: () {
              if (isCurrentStopDelivered) {
                ttsService.speak(
                  'This stop is already delivered. Please select the next buyer stop.',
                  languageCode: selectedLang.ttsLocale,
                );
              } else if (!allBagsVerified) {
                ttsService.speak(
                  'Please perform delivery verification scan for all packages before entering the OTP.',
                  languageCode: selectedLang.ttsLocale,
                );
              } else if (!photoAttached) {
                ttsService.speak(
                  'Bags verified. Please snap a produce photo of unloaded crates at the buyer receiving dock.',
                  languageCode: selectedLang.ttsLocale,
                );
              } else {
                ttsService.speak(
                  'Bags and photo verified. Ask buyer receiving supervisor for their 4-digit handover OTP.',
                  languageCode: selectedLang.ttsLocale,
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Multiple Delivery Stops Selector ─────────────────────
            if (hasMultipleStops) ...[
              _buildMultiStopSelector(trip),
              const SizedBox(height: 16),
            ],

            // ── Current Bulk Buyer Details Card ──────────────────────
            if (currentDeliveryStop != null) ...[
              _buildCurrentBuyerCard(currentDeliveryStop),
              const SizedBox(height: 16),
            ],

            // ── Geofence Check Card ─────────────────────────────────
            _buildGeofenceCard(
              deliveryState,
              currentDeliveryStop?.buyerName ?? trip.destination.name,
              strings,
            ),
            const SizedBox(height: 20),

            // ── If this stop is already delivered, show banner ───────
            if (isCurrentStopDelivered) ...[
              _buildStopDeliveredBanner(currentDeliveryStop!, trip),
              const SizedBox(height: 20),
            ] else ...[
              // ── Step 1: Delivery Verification Scan (Bag Matching) ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Step 1: Delivery Verification Scan',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: allBagsVerified
                          ? AppColors.statusDelivered.withOpacity(0.12)
                          : AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${trip.verifiedDeliveryCount}/${trip.waypoints.length} Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: allBagsVerified
                            ? AppColors.statusDelivered
                            : AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Verify each package being unloaded for this destination. Matches physical barcode or permanent marker Batch ID to prevent cargo mix-up.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...trip.waypoints.map((wp) => _buildDeliveryBagItem(wp)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showManualBatchDialog(trip),
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Enter Batch #',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: allBagsVerified
                          ? null
                          : () {
                              ref
                                  .read(activeTripProvider.notifier)
                                  .verifyAllDeliveryBatches();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      '✓ All packages verified for this destination!'),
                                  backgroundColor: AppColors.statusDelivered,
                                ),
                              );
                            },
                      icon: const Icon(Icons.checklist_rtl, size: 18),
                      label: const Text('Verify All Bags',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Step 2: Produce Unloading Photo Card ────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Step 2: Produce Photo Proof',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (!allBagsVerified)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock,
                              size: 12, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text('Locked',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Photograph produce safely unloaded at bulk buyer receiving dock or dark store cold bay.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              _buildPhotoCard(deliveryState, allBagsVerified),
              const SizedBox(height: 24),

              // ── Step 3: Bulk Buyer Handover OTP Card ───────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Step 3: Bulk Buyer Handover OTP',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.volume_up, color: AppColors.primary),
                    onPressed: () {
                      ttsService.speak(
                        'Ask bulk buyer receiving supervisor for their 4-digit handover OTP.',
                        languageCode: selectedLang.ttsLocale,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                canEnterOtp
                    ? 'Ask Bulk Buyer Inward Supervisor for 4-digit OTP to complete handover and unlock escrow payout.'
                    : '🔒 Locked: Verify all unloaded bags (Step 1) and attach produce photo (Step 2) to unlock OTP entry.',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      canEnterOtp ? AppColors.textSecondary : AppColors.danger,
                  fontWeight:
                      canEnterOtp ? FontWeight.normal : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildOtpInputBoxes(isEnabled: canEnterOtp),
              const SizedBox(height: 24),

              if (deliveryState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          deliveryState.errorMessage!,
                          style: const TextStyle(
                              color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Confirm Delivery Button ─────────────────────────────
              ElevatedButton(
                onPressed: !canEnterOtp ||
                        deliveryState.isSubmittingOtp ||
                        _otpValue.length < 4
                    ? null
                    : () async {
                        await _handleDeliveryConfirmation(
                          trip: trip,
                          currentStop: currentDeliveryStop,
                          strings: strings,
                          selectedLang: selectedLang,
                          ttsService: ttsService,
                        );
                      },
                child: deliveryState.isSubmittingOtp
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        hasMultipleStops && trip.pendingDeliveriesCount > 1
                            ? 'Confirm Handover for Stop ${_selectedStopIndex + 1}'
                            : 'Confirm Final Delivery & Disburse Payout',
                      ),
              ),
              const SizedBox(height: 14),
              if (canEnterOtp)
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      final testOtp =
                          currentDeliveryStop?.handoverOtp ?? '5678';
                      for (int i = 0; i < 4; i++) {
                        if (i < testOtp.length) {
                          _otpControllers[i].text = testOtp[i];
                        }
                      }
                      setState(() {});
                    },
                    icon: const Icon(Icons.key, size: 18),
                    label: Text(
                      'Auto-fill Buyer OTP (${currentDeliveryStop?.handoverOtp ?? '5678'})',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMultiStopSelector(RideTrip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CVRP Commercial Delivery Stops',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${trip.completedDeliveriesCount}/${trip.deliveryStops.length} Done',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: trip.deliveryStops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final stop = trip.deliveryStops[index];
              final isSelected = index == _selectedStopIndex;
              final isDelivered = stop.isDelivered;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedStopIndex = index);
                  _checkGeofenceForCurrentStop(trip);
                },
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.08)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDelivered
                              ? AppColors.statusDelivered
                              : AppColors.cardBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDelivered
                              ? AppColors.statusDelivered
                              : (isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isDelivered ? Icons.check : Icons.store,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Stop ${stop.stopOrder}: ${stop.buyerName}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stop.cropName} • ${stop.weightKg.toInt()}kg',
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentBuyerCard(DeliveryWaypoint stop) {
    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stop.buyerType,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Stop #${stop.stopOrder}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stop.buyerName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stop.address,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.scale, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '${stop.cropName}: ${stop.weightKg.toInt()} kg',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                stop.contactPhone,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopDeliveredBanner(DeliveryWaypoint stop, RideTrip trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusDelivered.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusDelivered, width: 1.5),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle,
                  color: AppColors.statusDelivered, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Handover Completed at this Buyer Dock!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.statusDelivered,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Handover verification with OTP & produce proof was recorded at ${stop.deliveredAt?.toLocal().toString().split('.')[0] ?? 'just now'}.',
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (trip.pendingDeliveriesCount > 0)
            ElevatedButton.icon(
              onPressed: () {
                final nextPending =
                    trip.deliveryStops.indexWhere((s) => !s.isDelivered);
                if (nextPending != -1) {
                  setState(() => _selectedStopIndex = nextPending);
                  _clearOtp();
                  ref.read(deliveryProvider.notifier).reset();
                  _checkGeofenceForCurrentStop(trip);
                }
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Proceed to Next Buyer Stop'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => context.go('/earnings'),
              icon: const Icon(Icons.account_balance_wallet, size: 16),
              label: const Text('View Disbursed Escrow Payout'),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDeliveryConfirmation({
    required RideTrip trip,
    required DeliveryWaypoint? currentStop,
    required AppStrings strings,
    required dynamic selectedLang,
    required TtsService ttsService,
  }) async {
    final success = await ref.read(deliveryProvider.notifier).submitProofAndOtp(
          tripId: trip.tripId,
          otp: _otpValue,
          destination: currentStop != null
              ? DropoffLocation(
                  name: currentStop.buyerName,
                  address: currentStop.address,
                  latitude: currentStop.latitude,
                  longitude: currentStop.longitude,
                )
              : trip.destination,
        );

    if (success && mounted) {
      if (currentStop != null) {
        ref
            .read(activeTripProvider.notifier)
            .markDeliveryStopCompleted(currentStop.stopId);
      }

      final updatedTrip = ref.read(activeTripProvider);
      final remaining = updatedTrip?.pendingDeliveriesCount ?? 0;

      if (remaining > 0 && currentStop != null) {
        ttsService.speak(
          'Handover completed for ${currentStop.buyerName}. Proceeding to next delivery stop.',
          languageCode: selectedLang.ttsLocale,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✓ Handover confirmed for ${currentStop.buyerName}! $remaining stop(s) remaining.'),
            backgroundColor: AppColors.statusDelivered,
            duration: const Duration(seconds: 3),
          ),
        );
        _clearOtp();
        ref.read(deliveryProvider.notifier).reset();
        final nextPending =
            updatedTrip!.deliveryStops.indexWhere((s) => !s.isDelivered);
        if (nextPending != -1) {
          setState(() => _selectedStopIndex = nextPending);
          _checkGeofenceForCurrentStop(updatedTrip);
        }
      } else {
        ref.read(activeTripProvider.notifier).completeTrip();
        ttsService.speak(
          'All commercial deliveries completed successfully! Instant payout disbursed to your RazorpayX Escrow wallet.',
          languageCode: selectedLang.ttsLocale,
        );
        context.go('/earnings');
      }
    }
  }

  Widget _buildDeliveryBagItem(PickupWaypoint wp) {
    final isVerified = wp.isDeliveryVerified;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? AppColors.statusDelivered : AppColors.cardBorder,
          width: isVerified ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppColors.statusDelivered.withOpacity(0.12)
                  : AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isVerified ? Icons.check_circle : Icons.inventory_2_outlined,
              color: isVerified ? AppColors.statusDelivered : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      wp.farmerName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Bag ${wp.batchId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${wp.cropName} • ${wp.weightKg.toStringAsFixed(0)} kg',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusDelivered.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, size: 14, color: AppColors.statusDelivered),
                  SizedBox(width: 4),
                  Text(
                    'Verified',
                    style: TextStyle(
                      color: AppColors.statusDelivered,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                ref
                    .read(activeTripProvider.notifier)
                    .verifyDeliveryBatch(wp.batchId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Verified ${wp.cropName} (${wp.batchId})'),
                    backgroundColor: AppColors.statusDelivered,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(80, 32),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Scan Bag'),
            ),
        ],
      ),
    );
  }

  Widget _buildGeofenceCard(
      DeliveryState state, String destinationName, AppStrings strings) {
    final passed = state.isGeofencePassed;
    final distance = state.currentDistanceMeters ?? 45.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed
            ? AppColors.statusDelivered.withOpacity(0.08)
            : AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: passed ? AppColors.statusDelivered : AppColors.accent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: passed
                  ? AppColors.statusDelivered.withOpacity(0.15)
                  : AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.verified_user : Icons.location_searching,
              color: passed ? AppColors.statusDelivered : AppColors.accent,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      passed
                          ? strings.geofenceCheckPassed
                          : 'Checking Proximity...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: passed
                            ? AppColors.statusDelivered
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (passed)
                      const Icon(Icons.check_circle,
                          color: AppColors.statusDelivered, size: 16),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  passed
                      ? 'You are ~${distance.toStringAsFixed(0)}m from $destinationName (Within 100m zone)'
                      : 'Move within 100m of delivery point to enable OTP submission.',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(DeliveryState state, bool isUnlocked) {
    final photoPath = state.capturedPhotoPath;

    return Column(
      children: [
        GestureDetector(
          onTap: !isUnlocked
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please verify all unloaded bags in Step 1 first.'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              : () async {
                  final result = await context.push<String>('/photo-capture');
                  if (result != null) {
                    ref.read(deliveryProvider.notifier).setPhotoPath(result);
                  }
                },
          child: Container(
            height: 125,
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.surface : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: photoPath != null
                    ? AppColors.primary
                    : (isUnlocked ? AppColors.cardBorder : Colors.grey.shade300),
                width: photoPath != null ? 2 : 1.5,
              ),
            ),
            child: photoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: AppColors.primary.withOpacity(0.08),
                          child: const Center(
                            child: Icon(Icons.check_circle_outline, color: AppColors.primary, size: 44),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.greenAccent, size: 14),
                                SizedBox(width: 4),
                                Text('Photo Attached',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUnlocked ? Icons.add_a_photo : Icons.lock_outline,
                          color: isUnlocked
                              ? AppColors.primary.withOpacity(0.8)
                              : Colors.grey,
                          size: 34,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isUnlocked
                              ? 'Tap to Snap Produce Unloading Photo'
                              : 'Produce Photo (Complete Step 1 First)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? AppColors.primary : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'Bulk buyer receiving dock produce snapshot',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        if (isUnlocked && photoPath == null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(deliveryProvider.notifier).setPhotoPath('mock://buyer_dock_crates_verified.jpg');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Sample produce photo attached (Buyer Receiving Dock proof).'),
                    backgroundColor: AppColors.statusDelivered,
                  ),
                );
              },
              icon: const Icon(Icons.auto_fix_high, size: 16),
              label: const Text('Attach Sample Produce Photo (Demo)', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOtpInputBoxes({bool isEnabled = true}) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == 3 ? 0 : 5,
            ),
            child: SizedBox(
              height: 68,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                enabled: isEnabled,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isEnabled ? AppColors.textPrimary : Colors.grey,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isEnabled ? AppColors.cardBorder : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
                  ),
                  filled: true,
                  fillColor: isEnabled ? AppColors.surface : Colors.grey.shade100,
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
            ),
          ),
        );
      }),
    );
  }
}
