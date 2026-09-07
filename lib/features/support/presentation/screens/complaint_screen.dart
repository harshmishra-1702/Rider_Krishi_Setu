// lib/features/support/presentation/screens/complaint_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../../../auth/domain/models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../trips/presentation/providers/trip_providers.dart';

class ComplaintScreen extends ConsumerStatefulWidget {
  const ComplaintScreen({super.key});

  @override
  ConsumerState<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends ConsumerState<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Mandi Dock Unloading Delay';
  String _selectedUrgency = 'High (Dock Blocked / Delay)';
  String _selectedTrip = 'TRIP-KS-8921 (Nashik APMC Mandi)';
  bool _hasPhotoProof = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Mandi Dock Unloading Delay',
    'Produce Weight / Deduction Dispute',
    'Road Blockage / Inaccessible Farm Route',
    'Fair Payout (Ton-Km) Calculation Query',
    'Farmer Gate Packaging / Missing Barcode',
    'App / QR Scanner Technical Glitch',
    'Vehicle Breakdown / Emergency Support',
  ];

  final List<String> _urgencyLevels = [
    'Normal (Resolution within 4 hours)',
    'High (Dock Blocked / Delay)',
    'Critical (Immediate Admin Call Required)',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 750)); // Network dispatch simulation

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final ticketId = 'TKT-ADM-${Random().nextInt(9000) + 1000}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                Icons.mark_email_read,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escalated to System Admin',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your grievance has been dispatched directly to the KrishiSetu Operations Admin Console with priority $_selectedUrgency.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Ticket #$ticketId',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'An Operations Executive will contact you and the mandi gate supervisor within 15 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Done & Return'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = ref.watch(activeTripProvider);
    final authState = ref.watch(authStateProvider);
    final driverName = authState is AuthAuthenticated ? authState.driver.name : 'Suresh Yadav';
    final vehiclePlate = authState is AuthAuthenticated ? authState.driver.vehicleNumber : 'MH-12-AB-1234';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver Grievance & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language (Stays on this page)',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Admin Escalation Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.admin_panel_settings,
                      color: AppColors.accent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Direct Escalation to System Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Issues filed here bypass local intermediaries and are directly monitored by the Regional Operations Control Center with live GPS telemetry tracking.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Driver & Vehicle Summary
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.badge, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Filing as: $driverName ($vehiclePlate)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Select Trip ID
            const Text(
              'Associated Trip / Route',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedTrip,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.local_shipping, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: [
                if (activeTrip != null)
                  DropdownMenuItem(
                    value: '${activeTrip.tripId} (${activeTrip.destination.name})',
                    child: Text(
                      '${activeTrip.tripId} (Active Route)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  const DropdownMenuItem(
                    value: 'TRIP-KS-8921 (Nashik APMC Mandi)',
                    child: Text('TRIP-KS-8921 (Active Nashik Mandi)'),
                  ),
                const DropdownMenuItem(
                  value: 'TRIP-KS-8840 (Pimpalgaon Sub-Mandi)',
                  child: Text('TRIP-KS-8840 (Past Settle)'),
                ),
                const DropdownMenuItem(
                  value: 'TRIP-KS-8715 (Dindori Pre-Cooling)',
                  child: Text('TRIP-KS-8715 (Past Settle)'),
                ),
                const DropdownMenuItem(
                  value: 'General Platform / Account Issue',
                  child: Text('General Platform / Account Issue'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedTrip = val);
              },
            ),
            const SizedBox(height: 16),

            // Issue Category
            const Text(
              'Issue Category',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),

            // Urgency Level
            const Text(
              'Urgency Level',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedUrgency,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.priority_high, color: AppColors.accent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: _urgencyLevels.map((u) {
                return DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedUrgency = val);
              },
            ),
            const SizedBox(height: 16),

            // Description text
            const Text(
              'Detailed Description of the Issue',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) {
                if (v == null || v.trim().length < 8) {
                  return 'Please provide at least 8 characters describing the issue.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'e.g., APMC Mandi gate entry dock 3 has been stalled for 1.5 hours without unloading receipt, or weighbridge deduction discrepancy...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 16),

            // Evidence Photo Attachment (Optional)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(
                  _hasPhotoProof ? Icons.check_circle : Icons.add_a_photo,
                  color: _hasPhotoProof ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  _hasPhotoProof ? 'Weighbridge / Gate Slip Attached' : 'Attach Photo Evidence (Slip/Gate Dock)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _hasPhotoProof ? 'slip_evidence_timestamped.jpg (240 KB)' : 'Optional proof to expedite admin arbitration',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: TextButton(
                  onPressed: () {
                    setState(() => _hasPhotoProof = !_hasPhotoProof);
                  },
                  child: Text(_hasPhotoProof ? 'Remove' : 'Attach'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitComplaint,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting
                  ? 'Dispatching to System Admin...'
                  : 'Submit Grievance to System Admin'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
