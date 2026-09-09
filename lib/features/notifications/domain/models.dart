// lib/features/notifications/domain/models.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum NotificationType {
  tripOffer,
  payoutCredited,
  routeAlert,
  qualityClearance,
  systemSupport;

  IconData get icon {
    switch (this) {
      case NotificationType.tripOffer:
        return Icons.local_shipping;
      case NotificationType.payoutCredited:
        return Icons.account_balance_wallet;
      case NotificationType.routeAlert:
        return Icons.navigation;
      case NotificationType.qualityClearance:
        return Icons.verified;
      case NotificationType.systemSupport:
        return Icons.headset_mic;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.tripOffer:
        return AppColors.primary;
      case NotificationType.payoutCredited:
        return AppColors.statusOnline;
      case NotificationType.routeAlert:
        return AppColors.accent;
      case NotificationType.qualityClearance:
        return AppColors.statusInTransit;
      case NotificationType.systemSupport:
        return AppColors.accent;
    }
  }
}

class DriverNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  const DriverNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  DriverNotification copyWith({
    bool? isRead,
  }) =>
      DriverNotification(
        id: id,
        title: title,
        message: message,
        type: type,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        actionRoute: actionRoute,
      );

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
