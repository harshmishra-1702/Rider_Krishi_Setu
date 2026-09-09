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
      message: '₹8,450.00 successfully secured & disbursed to your Escrow wallet via RazorpayX Smart Escrow.',
      type: NotificationType.payoutCredited,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      actionRoute: '/earnings',
    ),
    DriverNotification(
      id: 'NOTIF-003',
      title: 'Dock Slot Reserved (Blinkit #12)',
      message: 'Express unloading slot confirmed for 750kg Red Onions at MIDC Ambad Quick-Commerce Bay 2.',
      type: NotificationType.qualityClearance,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    DriverNotification(
      id: 'NOTIF-004',
      title: 'Inward Produce Quality Passed',
      message: '500kg Tomato crates passed electronic weighbridge and grade-A quality check at Reliance Fresh Dock 3.',
      type: NotificationType.qualityClearance,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    DriverNotification(
      id: 'NOTIF-005',
      title: 'Smart Route Optimization',
      message: 'AI Traffic Engine bypassed Highway 3 toll jam. Saved approx 18 minutes on Sawargaon connector.',
      type: NotificationType.routeAlert,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    DriverNotification(
      id: 'NOTIF-006',
      title: 'Grievance Compensation Credited',
      message: 'Ticket #TKT-ADM-8921: ₹250.00 dock waiting delay compensation approved and added to Escrow wallet.',
      type: NotificationType.systemSupport,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      actionRoute: '/earnings',
    ),
  ];

  static int _simCounter = 0;

  void simulateNewAlert() {
    _simCounter++;
    final alerts = [
      (
        title: 'Priority Farm Pickup Assigned',
        message: 'Sawargaon Farmer (Vijay More) has 750kg Table Grapes packaged and ready for loading.',
        type: NotificationType.tripOffer,
        route: '/route',
      ),
      (
        title: 'RazorpayX Milestone Advance Released',
        message: 'Advance fuel allowance of ₹1,200.00 released to your UPI account.',
        type: NotificationType.payoutCredited,
        route: '/earnings',
      ),
      (
        title: 'Cold Storage Bay Pre-Cooled',
        message: 'Symbiosis Hostel Mess cold room has pre-cooled and is standing by for fruit crates.',
        type: NotificationType.qualityClearance,
        route: null,
      ),
    ];
    final selected = alerts[_simCounter % alerts.length];
    addNotification(
      title: selected.title,
      message: selected.message,
      type: selected.type,
      actionRoute: selected.route,
    );
  }

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
