// lib/features/auth/presentation/screens/vehicle_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/services/tts_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_bottom_sheet.dart';
import '../../domain/models.dart';
import '../providers/auth_providers.dart';

class VehicleProfileScreen extends ConsumerStatefulWidget {
  final String? initialPhone;

  const VehicleProfileScreen({super.key, this.initialPhone});

  @override
  ConsumerState<VehicleProfileScreen> createState() =>
      _VehicleProfileScreenState();
}

class _VehicleProfileScreenState
    extends ConsumerState<VehicleProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;
  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _upiController = TextEditingController();

  VehicleTier _selectedTier = VehicleTier.small;
  String _selectedClusterHub = 'Reliance Fresh & Retail DCs (Nashik-Igatpuri)';
  bool _isReeferInsulated = false;

  final List<String> _clusterHubs = [
    'Reliance Fresh & Retail DCs (Nashik-Igatpuri)',
    'Blinkit & Zepto Dark Store Cluster (Nashik Central)',
    'Institutional Kitchens & University Hostel Messes',
    'BigBasket Fulfillment Warehouses (Ambad MIDC)',
    'Zomato Hyperpure Farm Aggregation Hub',
    'Pune Mega Dark Store & Wholesale Cluster',
  ];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone ?? '9876543210');
    _nameController.text = 'Suresh Yadav';
    _licenseController.text = 'MH-12-2019-0034521';
    _emergencyController.text = '9822334455';
    _vehicleNumberController.text = 'MH-12-AB-1234';
    _vehicleModelController.text = 'Tata Ace Gold';
    _upiController.text = 'suresh.yadav@upi';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _licenseController.dispose();
    _emergencyController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final strings = ref.watch(appStringsProvider);
    final selectedLang = ref.watch(selectedLanguageProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authStateProvider, (_, next) {
      if (next is AuthAuthenticated) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Driver Registration Successful!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome, ${_nameController.text.trim()}! Your vehicle ${_vehicleNumberController.text.trim()} is now activated on the KrishiSetu logistics network.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text('Go to Driver Dashboard'),
              ),
            ],
          ),
        );
      }
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver & Vehicle Onboarding'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go('/otp'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Change Language (Stays on this page)',
            onPressed: () => showLanguageBottomSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: strings.listenAudio,
            onPressed: () {
              final msg = '${strings.driverProfile}. ${strings.fullName}, ${strings.vehicleType}, ${strings.vehicleNumber}.';
              ref
                  .read(ttsServiceProvider)
                  .speak(msg, languageCode: selectedLang.ttsLocale);
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Top Onboarding Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'First-Time Logistics Registration',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Complete your 1-time profile to accept pooled farm-to-bulk-buyer delivery routes.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Personal & Driver Verification
            _buildSectionHeader('1. Driver Identification & Verification'),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPrivacyNotice(),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _nameController,
                      label: strings.fullName,
                      hint: 'As on Driving License',
                      icon: Icons.person,
                      validator: (v) =>
                          v == null || v.isEmpty ? '${strings.fullName} required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Registered Mobile Number',
                      hint: '9876543210',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.length != 10 ? 'Enter valid 10-digit phone' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _licenseController,
                      label: strings.drivingLicense,
                      hint: 'MH-12-2019-0034521',
                      icon: Icons.badge,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.isEmpty ? '${strings.drivingLicense} required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emergencyController,
                      label: 'Emergency / Alternate Contact Phone',
                      hint: '9822334455',
                      icon: Icons.contact_phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),

            // Section 2: Vehicle & Cargo Capacity
            _buildSectionHeader('2. Vehicle Fleet & Payload Tier'),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Vehicle Classification',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    _buildVehicleTierGrid(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _vehicleNumberController,
                      label: strings.vehicleNumber,
                      hint: 'MH-12-AB-1234',
                      icon: Icons.directions_car,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v == null || v.isEmpty ? '${strings.vehicleNumber} required' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _vehicleModelController,
                      label: strings.vehicleModel,
                      hint: 'e.g. Tata Ace Gold / Bolero Maxi',
                      icon: Icons.local_shipping,
                      validator: (v) =>
                          v == null || v.isEmpty ? '${strings.vehicleModel} required' : null,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isReeferInsulated,
                      onChanged: (val) => setState(() => _isReeferInsulated = val),
                      title: const Text('Insulated / Cold-Chain Cargo Box', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Eligible for higher-rate perishable runs (grapes/strawberries)', style: TextStyle(fontSize: 11)),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            // Section 3: Payout & Primary Delivery Cluster Hub
            _buildSectionHeader('3. Payout & Operating Delivery Cluster'),
            Card(
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _upiController,
                      label: strings.upiId,
                      hint: 'yourname@upi',
                      icon: Icons.account_balance_wallet,
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Enter valid UPI ID (e.g. name@upi)' : null,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Primary Operating Bulk Buyer Cluster',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedClusterHub,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.hub, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      items: _clusterHubs
                          .map((h) => DropdownMenuItem(
                                value: h,
                                child: Text(
                                  h,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedClusterHub = val);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.how_to_reg),
                label: Text(
                  isLoading ? 'Registering Driver...' : 'Complete Registration & Start',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withOpacity(0.35)),
      ),
      child: Row(
        children: const [
          Icon(Icons.verified_user, color: AppColors.accent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aadhaar Privacy Masked: [Aadhaar Redacted] • UIDAI compliant Digilocker verification',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildVehicleTierGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: VehicleTier.values.length,
      itemBuilder: (ctx, i) {
        final tier = VehicleTier.values[i];
        final isSelected = _selectedTier == tier;
        return GestureDetector(
          onTap: () => setState(() => _selectedTier = tier),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? tier.color.withOpacity(0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? tier.color : AppColors.cardBorder,
                width: isSelected ? 2.2 : 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(tier.icon,
                    color: isSelected ? tier.color : AppColors.textSecondary,
                    size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isSelected ? tier.color : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Up to ${tier.capacityDisplay}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, size: 16, color: tier.color),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authStateProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          licenseNumber: _licenseController.text.trim(),
          vehicleTier: _selectedTier,
          vehicleNumber: _vehicleNumberController.text.trim(),
          vehicleModel: _vehicleModelController.text.trim(),
          upiId: _upiController.text.trim().isEmpty
              ? null
              : _upiController.text.trim(),
        );
  }
}
