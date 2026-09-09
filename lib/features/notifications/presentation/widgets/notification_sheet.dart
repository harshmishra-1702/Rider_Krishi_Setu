// lib/features/notifications/presentation/widgets/notification_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/notification_providers.dart';

void showNotificationsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NotificationSheet(),
  );
}

class NotificationSheet extends ConsumerWidget {
  const NotificationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final strings = ref.watch(appStringsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.notifications,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        unreadCount > 0
                            ? '$unreadCount unread updates'
                            : 'All updates are read',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (notifications.isNotEmpty) ...[
                  TextButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).markAllAsRead();
                    },
                    child: Text(
                      strings.markAllRead,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 20, color: AppColors.textSecondary),
                    tooltip: strings.clearAll,
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).clearAll();
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // Notifications List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 54, color: AppColors.textSecondary.withOpacity(0.4)),
                          const SizedBox(height: 14),
                          const Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'All delivery route alerts, RazorpayX payouts, and bulk buyer updates will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Material(
                        color: item.isRead ? AppColors.surface : AppColors.primary.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            ref.read(notificationsProvider.notifier).markAsRead(item.id);
                            if (item.actionRoute != null) {
                              Navigator.pop(context);
                              context.push(item.actionRoute!);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: item.isRead
                                    ? AppColors.cardBorder
                                    : AppColors.primary.withOpacity(0.35),
                                width: item.isRead ? 1 : 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: item.type.color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(item.type.icon, color: item.type.color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: item.isRead
                                                    ? FontWeight.w600
                                                    : FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.timeAgo,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.message,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!item.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
