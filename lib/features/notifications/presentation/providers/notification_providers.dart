// lib/features/notifications/presentation/providers/notification_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';

class NotificationsNotifier extends StateNotifier<List<DriverNotification>> {
  NotificationsNotifier() : super(_initialNotifications);

  static final List<DriverNotification> _initialNotifications = [
    DriverNotification(
      id: 'NOTIF-001',
      title: 'Bulk Buyer Delivery Assigned',
      message: 'New CVRP Route: Pickups at Khuntewadi & Sawargaon, direct delivery to Reliance Fresh DC & Blinkit Dark Store.',
      type: NotificationType.tripOffer,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      actionRoute: '/route',
    ),
    DriverNotification(
      id: 'NOTIF-002',
      title: 'Instant Payout Settled (RazorpayX)',
      message: '₹3,000.00 successfully transferred to your linked UPI ID (suresh.yadav@upi) via RazorpayX Smart Escrow.',
      type: NotificationType.payoutCredited,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      actionRoute: '/earnings',
    ),
    DriverNotification(
      id: 'NOTIF-003',
      title: 'Inward Produce Clearance',
      message: '500kg Tomato crates passed electronic weighbridge and grade-A quality check at Reliance Fresh Receiving Dock 3.',
      type: NotificationType.qualityClearance,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    DriverNotification(
      id: 'NOTIF-004',
      title: 'Smart Route Optimization',
      message: 'AI Traffic Engine bypassed Highway 3 toll jam. Saved approx 18 minutes on Sawargaon connector.',
      type: NotificationType.routeAlert,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void clearAll() {
    state = [];
  }

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? actionRoute,
  }) {
    final notif = DriverNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      actionRoute: actionRoute,
    );
    state = [notif, ...state];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<DriverNotification>>((ref) {
  return NotificationsNotifier();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});
