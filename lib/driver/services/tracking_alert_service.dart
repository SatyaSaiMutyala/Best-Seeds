import 'dart:async';
import 'dart:io';

import 'package:bestseeds/driver/service/auth_service.dart';
import 'package:bestseeds/driver/services/driver_storage_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Periodically checks driver device state (GPS, location, internet)
/// and sends alerts to the backend every 5 minutes.
class TrackingAlertService {
  static Timer? _timer;
  static const _interval = Duration(minutes: 5);
  static final AuthService _authService = AuthService();
  static final DriverStorageService _storage = DriverStorageService();
  static const MethodChannel _deviceInfoChannel =
      MethodChannel('bestseeds/device_info');
  static String? _pendingIssueType;
  static String? _lastDetectedIssueType;

  /// Start the periodic alert checker after driver login.
  static void start() {
    stop(); // cancel any existing timer
    // Run once immediately, then every 5 minutes
    _checkAndSendAlert();
    _timer = Timer.periodic(_interval, (_) => _checkAndSendAlert());
  }

  /// Stop the periodic alert checker (call on logout).
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _pendingIssueType = null;
    _lastDetectedIssueType = null;
  }

  static bool get isRunning => _timer != null && _timer!.isActive;

  static Future<void> _checkAndSendAlert() async {
    final token = _storage.getToken();
    if (token == null) {
      stop();
      return;
    }

    final issueType = await _detectIssue();
    if (issueType == null) {
      await _flushPendingAlert(token);
      _lastDetectedIssueType = null;
      return;
    }

    if (issueType == _lastDetectedIssueType) {
      print('TRACKING ALERT: Same issue still active, skipping -> $issueType');
      return;
    }

    _lastDetectedIssueType = issueType;

    if (issueType == 'no_internet') {
      // We cannot notify the backend while offline, so hold the alert until
      // connectivity returns and the timer runs again.
      _pendingIssueType = issueType;
      print('TRACKING ALERT: Internet unavailable, alert queued for retry');
      return;
    }

    try {
      await _flushPendingAlert(token);
      await _authService.sendTrackingAlert(
        token: token,
        issueType: issueType,
      );
      print('TRACKING ALERT: Sent alert -> $issueType');
    } catch (e) {
      print('TRACKING ALERT: Failed to send alert -> $e');
    }
  }

  static Future<void> _flushPendingAlert(String token) async {
    final pendingIssueType = _pendingIssueType;
    if (pendingIssueType == null) return;

    try {
      await _authService.sendTrackingAlert(
        token: token,
        issueType: pendingIssueType,
      );
      _pendingIssueType = null;
      print('TRACKING ALERT: Sent queued alert -> $pendingIssueType');
    } catch (e) {
      print('TRACKING ALERT: Failed to send queued alert -> $e');
    }
  }

  /// Returns the issue type string or null if everything is normal.
  static Future<String?> _detectIssue() async {
    // 1. Check internet connectivity
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.contains(ConnectivityResult.none)) {
        return 'no_internet';
      }
    } catch (_) {
      return 'no_internet';
    }

    // 2. Check if location service (GPS hardware) is enabled
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'gps_off';
      }
    } catch (_) {
      return 'gps_off';
    }

    // 3. Check location permission (user may have revoked it)
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return 'location_off';
      }
    } catch (_) {
      return 'location_off';
    }

    // 4. Check battery level on Android via platform channel
    try {
      if (Platform.isAndroid) {
        final batteryLevel =
            await _deviceInfoChannel.invokeMethod<int>('getBatteryLevel');
        if (batteryLevel != null && batteryLevel <= 15) {
          return 'battery_low';
        }
      }
    } catch (_) {
      // Ignore battery read errors; they should not block tracking.
    }

    return null; // all good
  }
}
