import 'dart:async';

import 'package:bestseeds/employee/models/tracking_alert_model.dart';
import 'package:bestseeds/employee/repository/auth_repository.dart';
import 'package:bestseeds/employee/services/storage_service.dart';
import 'package:get/get.dart';

class EmployeeNotificationController extends GetxController {
  final AuthRepository _repo = AuthRepository();
  final StorageService _storage = StorageService();

  final alerts = <TrackingAlert>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;

  Timer? _pollTimer;

  @override
  void onInit() {
    super.onInit();
    fetchAlerts();
    // Poll every 30 seconds for new alerts
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchAlerts(),
    );
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchAlerts() async {
    final token = _storage.getToken();
    if (token == null) return;

    try {
      final response = await _repo.getTrackingAlertStatus(token: token);

      // Replace the entire list with the latest server snapshot. The API
      // returns alerts ordered newest-first.
      alerts.assignAll(response.alerts);

      // Badge count comes straight from the server's unread_count, so it
      // reflects the true number of unread alerts (not a local accumulator).
      unreadCount.value = response.unreadCount;
    } catch (e) {
      print('NOTIFICATION CONTROLLER: Error fetching alerts -> $e');
    }
  }

  /// Marks all alerts as read on the server, then refreshes the list so
  /// `is_read` flips to true on each card and the badge clears.
  Future<void> markAllRead() async {
    final token = _storage.getToken();
    if (token == null) return;

    try {
      await _repo.markTrackingAlertsRead(token: token);
      // Optimistic local update so the UI updates immediately.
      unreadCount.value = 0;
      alerts.assignAll(
        alerts
            .map((a) => TrackingAlert(
                  id: a.id,
                  bookingId: a.bookingId,
                  driverId: a.driverId,
                  reason: a.reason,
                  driverName: a.driverName,
                  driverMobile: a.driverMobile,
                  driverLocationName: a.driverLocationName,
                  time: a.time,
                  isRead: true,
                ))
            .toList(),
      );
    } catch (e) {
      print('NOTIFICATION CONTROLLER: Error marking alerts read -> $e');
    }
  }
}
