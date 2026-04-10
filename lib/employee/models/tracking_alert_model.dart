class TrackingAlert {
  final int id;
  final int bookingId;
  final int driverId;
  final String reason;
  final String driverName;
  final String driverMobile;
  final String driverLocationName;
  final String time;
  final bool isRead;

  TrackingAlert({
    required this.id,
    required this.bookingId,
    required this.driverId,
    required this.reason,
    required this.driverName,
    required this.driverMobile,
    required this.driverLocationName,
    required this.time,
    required this.isRead,
  });

  factory TrackingAlert.fromJson(Map<String, dynamic> json) {
    return TrackingAlert(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      driverId: json['driver_id'] ?? 0,
      reason: json['reason'] ?? '',
      driverName: json['driver_name'] ?? '',
      driverMobile: json['driver_mobile'] ?? '',
      // API field is `location_name`; keep `driver_location_name` as a fallback
      // for any older payloads.
      driverLocationName:
          json['location_name'] ?? json['driver_location_name'] ?? '',
      time: json['time'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }
}

class TrackingAlertResponse {
  final bool status;
  final int unreadCount;
  final List<TrackingAlert> alerts;

  TrackingAlertResponse({
    required this.status,
    required this.unreadCount,
    required this.alerts,
  });

  factory TrackingAlertResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['alerts'];
    final list = <TrackingAlert>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          list.add(TrackingAlert.fromJson(item));
        }
      }
    }
    final rawCount = json['unread_count'];
    final unread = rawCount is int
        ? rawCount
        : int.tryParse('${rawCount ?? ''}') ?? 0;
    return TrackingAlertResponse(
      status: json['status'] ?? false,
      unreadCount: unread,
      alerts: list,
    );
  }

  bool get hasAlerts => alerts.isNotEmpty;
}
