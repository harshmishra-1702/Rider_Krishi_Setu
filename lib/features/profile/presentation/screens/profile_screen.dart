// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../../../auth/domain/models.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final driver = authState is AuthAuthenticated
        ? authState.driver
        : const Driver(
            driverId: 'DRV-KS-0042',
            name: 'Suresh Yadav',
            phone: '+919876543210',
            aadhaar: '[Aadhaar Redacted]',
            licenseNumber: 'MH-12-20190034521',
            vehicleTier: VehicleTier.small,
            vehicleNumber: 'MH-12-AB-1234',
            vehicleModel: 'Tata Ace Gold',
            capacityKg: 1500,
            rating: 4.8,
            totalTrips: 127,
            upiId: 'suresh.yadav@upi',
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver Profile'),
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
            tooltip: 'Change Language (Stays on this page)',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Profile Header ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        driver.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: AppColors.accent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${driver.rating} • ${driver.totalTrips} Completed Trips',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Privacy & Verification Details ────────────────────────
          _buildSectionHeader('Identity & Compliance'),
          Card(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _buildTile(
                  icon: Icons.security,
                  title: 'Aadhaar Verification',
                  value: driver.aadhaar, // Always '[Aadhaar Redacted]'
                  trailingIcon: Icons.verified,
                  trailingColor: AppColors.primary,
                ),
                const Divider(height: 1),
                _buildTile(
                  icon: Icons.badge,
                  title: 'Driving License',
                  value: driver.licenseNumber,
                  trailingIcon: Icons.check_circle_outline,
                  trailingColor: AppColors.primary,
                ),
                const Divider(height: 1),
                _buildTile(
                  icon: Icons.account_balance_wallet,
                  title: 'Disbursement UPI',
                  value: driver.upiId ?? 'suresh.yadav@upi',
                ),
              ],
            ),
          ),

          // ── Vehicle Profile Details ──────────────────────────────
          _buildSectionHeader('Heterogeneous Fleet Classification'),
          Card(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _buildTile(
                  icon: driver.vehicleTier.icon,
                  title: 'Vehicle Tier',
                  value:
                      '${driver.vehicleTier.label} (${driver.vehicleTier.subtitle})',
                ),
                const Divider(height: 1),
                _buildTile(
                  icon: Icons.directions_car,
                  title: 'Vehicle Model',
                  value: driver.vehicleModel,
                ),
                const Divider(height: 1),
                _buildTile(
                  icon: Icons.confirmation_number,
                  title: 'Plate Number',
                  value: driver.vehicleNumber,
                ),
                const Divider(height: 1),
                _buildTile(
                  icon: Icons.scale,
                  title: 'Cargo Payload Limit',
                  value:
                      '${driver.capacityKg.toStringAsFixed(0)} kg (${(driver.capacityKg / 1000).toStringAsFixed(1)} Tonnes)',
                ),
              ],
            ),
          ),

          // ── Farmer & Buyer Reviews & Ratings ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader('Verified Reviews & Ratings'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${driver.rating} / 5.0',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFFB78103),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildReviewCard(
            author: 'Ramesh Kumar',
            role: 'Farmer • Khuntewadi',
            rating: 5.0,
            comment:
                'Driver arrived exactly on schedule at farm gate. Handled tomato crates very gently.',
          ),
          _buildReviewCard(
            author: 'Reliance Fresh Inward Lead',
            role: 'Bulk Buyer • Retail DC',
            rating: 4.9,
            comment:
                'Prompt unloading and accurate batch verification with permanent marker IDs matched.',
          ),
          _buildReviewCard(
            author: 'Vijay More',
            role: 'Farmer • Sawargaon',
            rating: 4.8,
            comment:
                'Clean vehicle floor, polite behavior and verified bag weights.',
          ),
          const SizedBox(height: 16),

          // ── Help, Grievance & Operations Support ────────────────
          _buildSectionHeader('Help, Grievance & 24/7 Operations Support'),
          Card(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.assignment_late_outlined, color: AppColors.accent, size: 20),
                  ),
                  title: const Text('File Grievance / Report Issue',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Report buyer gate delay, tare weight discrepancy, or transit fault',
                      style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () => context.push('/complaint'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk, color: Colors.green, size: 20),
                  ),
                  title: const Text('24/7 Fleet Operations Hotline',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Toll-Free 1800-209-8899 • Immediate admin call support',
                      style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.call, size: 18, color: Colors.green),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('📞 Calling KrishiSetu Operations Hotline: 1800-209-8899...'),
                        backgroundColor: AppColors.primary,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, color: AppColors.primary, size: 20),
                  ),
                  title: const Text('Ticket #TKT-ADM-8921',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Dock Delay Claim: ₹250.00 reimbursed to Escrow wallet',
                      style: TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.statusDelivered.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('RESOLVED',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusDelivered)),
                  ),
                ),
              ],
            ),
          ),

          // ── Language & App Preferences ────────────────────────────
          _buildSectionHeader('App Settings & Diagnostics'),
          Card(
            margin: const EdgeInsets.only(top: 8, bottom: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: const Text('App Language',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${selectedLang.nativeName} (${selectedLang.name})'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showLanguageBottomSheet(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync, color: AppColors.primary),
                  title: const Text('Offline Sync Status',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('SQLite DB Active • All pings cached'),
                  trailing: const Icon(Icons.cloud_done,
                      color: AppColors.primary),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Offline data synchronized with server.'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Sign Out Button ───────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/otp');
              }
            },
            icon: const Icon(Icons.logout, color: AppColors.danger),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.danger),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildReviewCard({
    required String author,
    required String role,
    required double rating,
    required String comment,
  }) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      author,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '"$comment"',
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

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String value,
    IconData? trailingIcon,
    Color? trailingColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: trailingIcon != null
          ? Icon(trailingIcon, color: trailingColor, size: 20)
          : null,
    );
  }
}
