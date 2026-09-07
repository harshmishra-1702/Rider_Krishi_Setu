// lib/features/verification/presentation/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../trips/presentation/providers/trip_providers.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  final String stopId;
  final String? cropName;
  final String? weightKg;
  final String? batchId;

  const QrScannerScreen({
    super.key,
    required this.stopId,
    this.cropName,
    this.weightKg,
    this.batchId,
  });

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _effectiveBatchId {
    final b = widget.batchId?.trim();
    if (b != null && b.isNotEmpty && b != '#') {
      return b.startsWith('#') ? b : '#$b';
    }
    return '#4092';
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue ?? _effectiveBatchId;
      _handleScannedCode(code);
    }
  }

  Future<void> _handleScannedCode(String rawCode) async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    String displayBatch = rawCode.trim();
    if (displayBatch.isEmpty || displayBatch == '#' || displayBatch == 'BATCH-KS-AUTO') {
      displayBatch = _effectiveBatchId;
    } else if (!displayBatch.startsWith('#') && !displayBatch.startsWith('BATCH-')) {
      displayBatch = '#$displayBatch';
    }

    final success = await ref
        .read(activeTripProvider.notifier)
        .verifyPickup(widget.stopId, displayBatch);

    if (!mounted) return;

    if (success) {
      _showSuccessDialog(displayBatch);
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to verify batch. Please retry.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Batch Verified!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harvest batch for ${widget.cropName ?? "Produce"} (${widget.weightKg ?? "500"} kg) has been verified and loaded into cargo.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                'BATCH ID : \'$code\'',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              context.pop(); // Return to route
            },
            child: const Text('Continue Trip'),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog() {
    final expected = _effectiveBatchId;
    final ctrl = TextEditingController(text: expected.replaceAll('#', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.edit_note, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Low-Tech Bag Fallback'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'If the farmer has no printer or the QR code is smudged, enter the 4-digit Batch ID written with permanent marker on the bag:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.text,
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
            const SizedBox(height: 8),
            Text(
              'Expected Bag Code: $expected',
              style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
            ),
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
                Navigator.pop(ctx);
                _handleScannedCode('#$val');
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Farm Batch QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle Flashlight',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch Camera',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera Viewfinder ────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Target Bag Header Overlay ────────────────────────────
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.label, color: AppColors.accent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Target Bag: $_effectiveBatchId (${widget.cropName ?? "Crop"})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scanner Overlay Frame ────────────────────────────────
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primary, width: 5),
                          left: BorderSide(color: AppColors.primary, width: 5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.primary, width: 5),
                          right: BorderSide(color: AppColors.primary, width: 5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary, width: 5),
                          left: BorderSide(color: AppColors.primary, width: 5),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.primary, width: 5),
                          right: BorderSide(color: AppColors.primary, width: 5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Instructions & Manual Fallback Button ─────────────────
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Align farmer QR code inside the box to verify ${widget.cropName ?? "produce"} (${widget.weightKg ?? "500"} kg)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Manual Fallback button
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _showManualEntryDialog,
                  icon: const Icon(Icons.edit_note, color: AppColors.textPrimary),
                  label: Text(
                    'Manual Batch ID Fallback ($_effectiveBatchId)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 8),
                // Simulator/Desktop bypass button
                OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => _handleScannedCode(_effectiveBatchId),
                  icon: const Icon(Icons.developer_mode, color: Colors.white70, size: 18),
                  label: Text(
                    'Simulate Camera Scan ($_effectiveBatchId)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white38),
                    backgroundColor: Colors.black38,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
