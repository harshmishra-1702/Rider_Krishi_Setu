// lib/features/trips/presentation/widgets/driver_status_header.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/models.dart';

class DriverStatusHeader extends StatelessWidget {
  final Driver? driver;
  final bool isOnline;
  final VoidCallback onToggleOnline;
  final VoidCallback? onSupportTap;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onNotificationTap;
  final int unreadNotificationsCount;
  final String? onlineLabel;
  final String? offlineLabel;

  const DriverStatusHeader({
    super.key,
    this.driver,
    required this.isOnline,
    required this.onToggleOnline,
    this.onSupportTap,
    this.onLanguageTap,
    this.onNotificationTap,
    this.unreadNotificationsCount = 0,
    this.onlineLabel,
    this.offlineLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo / Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          // Driver info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  driver?.name ?? 'Suresh Yadav',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(
                      driver?.vehicleTier.icon ?? Icons.local_shipping,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${driver?.vehicleTier.label ?? "Small"} • ${driver?.vehicleNumber ?? "MH-12-AB-1234"}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification Bell with Badge
          if (onNotificationTap != null)
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 21),
                  tooltip: 'Notifications',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onNotificationTap,
                ),
                if (unreadNotificationsCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      child: Text(
                        unreadNotificationsCount > 9 ? '9+' : '$unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          if (onLanguageTap != null)
            IconButton(
              icon: const Icon(Icons.language, color: AppColors.primary, size: 20),
              tooltip: 'Change Language (Stays on this page)',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onLanguageTap,
            ),
          if (onSupportTap != null)
            IconButton(
              icon: const Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 20),
              tooltip: 'Grievance & Support',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onSupportTap,
            ),
          const SizedBox(width: 4),
          // Online/offline toggle
          GestureDetector(
            onTap: onToggleOnline,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: isOnline ? AppColors.statusOnline : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.white : AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isOnline ? (onlineLabel ?? 'Online') : (offlineLabel ?? 'Offline'),
                    style: TextStyle(
                      color: isOnline ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
