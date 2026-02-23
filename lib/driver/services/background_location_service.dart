import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- Constants (duplicated here because this file must be self-contained
//     for the background isolate; it cannot import Flutter-widget-dependent files) ---
const String _baseUrl =
    'https://aliceblue-wallaby-326294.hostingersite.com/api/';
const String _locationUpdateEndpoint = 'driver/location/update';
const String _googleApiKey = 'AIzaSyDLVwCSkXWOjo49WNNwx7o0DSwomoFvbP0';
const String _tokenKey = 'driver_token';
const String _serviceRunningKey = 'bg_location_service_running';

// Notification channel constants
const String _notificationChannelId = 'bestseeds_location_channel';
const String _notificationChannelName = 'Location Tracking';
const int _notificationId = 888;

class BackgroundLocationService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  /// Initialize the background service. Call once at app startup (in main()).
  static Future<void> initialize() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Shows notification while tracking delivery location',
      importance: Importance.low, // Low = no sound, just persistent icon
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        foregroundServiceNotificationId: _notificationId,
        initialNotificationTitle: 'Best Seeds',
        initialNotificationContent: 'Tracking your delivery journey...',
        notificationChannelId: _notificationChannelId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// Start the background location service.
  static Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_serviceRunningKey, true);

    final isRunning = await _service.isRunning();
    if (!isRunning) {
      await _service.startService();
    }
  }

  /// Stop the background location service.
  static Future<void> stop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_serviceRunningKey, false);

    final isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke('stop');
    }
  }

  /// Check if the service is currently running.
  static Future<bool> isRunning() async {
    return await _service.isRunning();
  }
}

// =============================================================================
// BACKGROUND ISOLATE ENTRY POINT
// Everything below runs in a SEPARATE Dart isolate on Android.
// It has NO access to the main isolate's memory, widgets, or global variables.
// =============================================================================

@pragma('vm:entry-point')
Future<void> _onStart(ServiceInstance service) async {
  // Required for plugins to work in background isolate
  DartPluginRegistrant.ensureInitialized();

  Timer? locationTimer;

  // Listen for stop command from UI isolate
  service.on('stop').listen((_) {
    locationTimer?.cancel();
    service.stopSelf();
  });

  // The core location sending function
  Future<void> sendLocation() async {
    try {
      // Re-initialize SharedPreferences in this isolate
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Force reload to get latest values
      final token = prefs.getString(_tokenKey);

      if (token == null || token.isEmpty) {
        print('BackgroundLocationService: No token found, stopping.');
        locationTimer?.cancel();
        service.stopSelf();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      print('BackgroundLocationService: Position -> '
          'lat=${position.latitude}, lng=${position.longitude}');

      // Reverse geocode using Google HTTP API (not the geocoding package)
      final locationName = await _reverseGeocodeHttp(
        position.latitude,
        position.longitude,
      );

      // POST to API
      final response = await http.post(
        Uri.parse('$_baseUrl$_locationUpdateEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'lat': position.latitude,
          'lng': position.longitude,
          'location_name': locationName ?? 'Live vehicle location',
        }),
      );

      print('BackgroundLocationService: API Response ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        // Check if journey is still active
        if (data['status'] == false) {
          print('BackgroundLocationService: Journey ended, stopping service.');
          locationTimer?.cancel();
          await prefs.setBool(_serviceRunningKey, false);
          service.stopSelf();
          return;
        }

        // Update notification with current location
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: 'Best Seeds - Delivering',
            content: 'Location: ${locationName ?? 'Tracking active...'}',
          );
        }

        // Send data to UI isolate (if app is open)
        service.invoke('locationUpdate', {
          'lat': position.latitude,
          'lng': position.longitude,
          'location_name': locationName,
          'timestamp': DateTime.now().toIso8601String(),
        });

        print('BackgroundLocationService: Location sent successfully.');
      } else {
        print('BackgroundLocationService: API error ${response.statusCode}');
      }
    } catch (e, stack) {
      print('BackgroundLocationService ERROR: $e');
      print('$stack');
    }
  }

  // Send immediately on start
  await sendLocation();

  // Then every 2 minutes
  locationTimer = Timer.periodic(
    const Duration(minutes: 2),
    (_) => sendLocation(),
  );
}

/// iOS background handler
@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final token = prefs.getString(_tokenKey);
    if (token == null) return false;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 30),
    );

    final locationName = await _reverseGeocodeHttp(
      position.latitude,
      position.longitude,
    );

    final response = await http.post(
      Uri.parse('$_baseUrl$_locationUpdateEndpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lat': position.latitude,
        'lng': position.longitude,
        'location_name': locationName ?? 'Live vehicle location',
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data['status'] == false) {
        await prefs.setBool(_serviceRunningKey, false);
        service.stopSelf();
        return false;
      }
    }
    return true;
  } catch (e) {
    print('iOS background error: $e');
    return false;
  }
}

/// HTTP-based reverse geocoding that works in background isolate.
Future<String?> _reverseGeocodeHttp(double lat, double lng) async {
  try {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&result_type=sublocality|locality|administrative_area_level_1'
      '&language=en'
      '&key=$_googleApiKey',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    if (data['status'] != 'OK') return null;

    final results = data['results'] as List;
    if (results.isEmpty) return null;

    String? subLocality;
    String? locality;
    String? adminArea;

    for (var component in results[0]['address_components']) {
      final types = (component['types'] as List).cast<String>();
      if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        subLocality = component['long_name'];
      }
      if (types.contains('locality')) {
        locality = component['long_name'];
      }
      if (types.contains('administrative_area_level_1')) {
        adminArea = component['long_name'];
      }
    }

    return [subLocality, locality, adminArea]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');
  } catch (e) {
    print('Background reverse geocoding failed: $e');
    return null;
  }
}
