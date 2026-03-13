import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapsService {
  static const String _apiKey = 'AIzaSyDLVwCSkXWOjo49WNNwx7o0DSwomoFvbP0';

  /// Get directions between two points and return polyline points
  static Future<List<LatLng>> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      String waypointsStr = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        waypointsStr = '&waypoints=${waypoints.map((wp) => '${wp.latitude},${wp.longitude}').join('|')}';
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '$waypointsStr'
        '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        debugPrint('Directions API error: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        debugPrint('Directions API status: ${data['status']}');
        return [];
      }

      // Decode the polyline from the response
      final encodedPolyline =
          data['routes'][0]['overview_polyline']['points'] as String;

      return _decodePolyline(encodedPolyline);
    } catch (e) {
      debugPrint('Error getting directions: $e');
      return [];
    }
  }

  /// Geocode an address to get LatLng coordinates
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);

      if (data['status'] != 'OK') return null;

      final location = data['results'][0]['geometry']['location'];

      return LatLng(location['lat'], location['lng']);
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to get neighborhood/area name.
  /// Prefers sublocality (e.g. "Kothaguda", "Madhapur") over city ("Hyderabad").
  static Future<String?> reverseGeocode(LatLng location) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${location.latitude},${location.longitude}'
        '&result_type=sublocality_level_1|sublocality|neighborhood|locality|administrative_area_level_3'
        '&language=en'
        '&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if (data['status'] != 'OK') return null;

      final results = data['results'] as List;
      if (results.isEmpty) return null;

      // Priority: sublocality > neighborhood > locality (city)
      const priority = [
        'sublocality_level_1',
        'sublocality',
        'neighborhood',
        'locality',
        'administrative_area_level_3',
      ];

      for (final type in priority) {
        for (final result in results) {
          final components = result['address_components'] as List;
          for (final component in components) {
            final types = component['types'] as List;
            if (types.contains(type)) {
              return component['long_name'];
            }
          }
        }
      }

      return results[0]['formatted_address']?.toString().split(',').first;
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Get full route from origin to destination with intermediate stops.
  /// When [driverPosition] is provided, the polyline is split into
  /// completed (green) and remaining (blue) segments.
  /// Supports multi-drop routes with [routeWaypoints].
  static Future<Map<String, dynamic>> getRouteWithStops({
    required LatLng origin,
    required LatLng destination,
    LatLng? driverPosition,
    List<LatLng> routeWaypoints = const [],
    int maxStops = 5,
  }) async {
    try {
      // Build waypoints for Directions API
      // When route waypoints exist (multi-drop), only use drop waypoints — NOT driver position.
      // The driver position will be used to split the polyline into completed/remaining.
      // When no route waypoints, use driver position as waypoint (original behavior).
      List<String> allWaypoints = [];
      if (routeWaypoints.isNotEmpty) {
        for (final wp in routeWaypoints) {
          allWaypoints.add('${wp.latitude},${wp.longitude}');
        }
      } else if (driverPosition != null) {
        allWaypoints.add('${driverPosition.latitude},${driverPosition.longitude}');
      }
      String waypointsParam = '';
      if (allWaypoints.isNotEmpty) {
        waypointsParam = '&waypoints=${allWaypoints.join('|')}';
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '$waypointsParam'
        '&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return {};

      final data = json.decode(response.body);
      if (data['status'] != 'OK') return {};

      final route = data['routes'][0];
      final legs = route['legs'] as List;

      // Decode per-leg polylines for accuracy
      List<LatLng> completedPoints = [];
      List<LatLng> remainingPoints = [];
      int totalDurationSeconds = 0;
      int totalDistanceMeters = 0;
      int remainingSeconds = 0;
      int completedSeconds = 0;

      if (routeWaypoints.isNotEmpty && driverPosition != null) {
        // Multi-drop route with driver position:
        // Route goes: origin → drop1 → drop2 → ... → destination (driver NOT a waypoint)
        // Split the polyline at the driver's actual position for green/blue coloring
        List<LatLng> allPoints = [];
        for (final leg in legs) {
          allPoints.addAll(_decodeStepsPolyline(leg['steps'] as List));
          totalDurationSeconds += leg['duration']['value'] as int;
          totalDistanceMeters += leg['distance']['value'] as int;
        }

        // Find the closest point on the polyline to the driver's actual position
        int driverIdx = _findClosestPointIndex(allPoints, driverPosition);

        // Split at driver's actual position
        completedPoints = allPoints.sublist(0, driverIdx + 1);
        remainingPoints = allPoints.sublist(driverIdx);

        // Estimate completed/remaining durations by distance fraction
        double totalDist = 0;
        for (int i = 1; i < allPoints.length; i++) {
          totalDist += _haversineDistance(allPoints[i - 1], allPoints[i]);
        }
        double completedDist = 0;
        for (int i = 1; i < completedPoints.length; i++) {
          completedDist += _haversineDistance(completedPoints[i - 1], completedPoints[i]);
        }
        double fraction = totalDist > 0 ? completedDist / totalDist : 0;
        completedSeconds = (totalDurationSeconds * fraction).round();
        remainingSeconds = totalDurationSeconds - completedSeconds;
      } else if (driverPosition != null && legs.length >= 2) {
        // Single-drop route with driver as waypoint (original behavior)
        // Leg 0: origin → driver (completed), Leg 1: driver → destination (remaining)
        completedPoints = _decodeStepsPolyline(legs[0]['steps'] as List);
        remainingPoints = _decodeStepsPolyline(legs[1]['steps'] as List);
        completedSeconds = legs[0]['duration']['value'] as int;
        remainingSeconds = legs[1]['duration']['value'] as int;
        totalDurationSeconds = completedSeconds + remainingSeconds;
        totalDistanceMeters = (legs[0]['distance']['value'] as int) +
            (legs[1]['distance']['value'] as int);
      } else if (routeWaypoints.isNotEmpty && legs.length >= 2) {
        // Waypoints but no driver position — all legs combined as remaining
        for (final leg in legs) {
          remainingPoints.addAll(_decodeStepsPolyline(leg['steps'] as List));
          totalDurationSeconds += leg['duration']['value'] as int;
          totalDistanceMeters += leg['distance']['value'] as int;
        }
        remainingSeconds = totalDurationSeconds;
      } else {
        // No driver position, no waypoints — single leg, full route as remaining
        final encodedPolyline =
            route['overview_polyline']['points'] as String;
        remainingPoints = _decodePolyline(encodedPolyline);
        totalDurationSeconds = legs[0]['duration']['value'] as int;
        totalDistanceMeters = legs[0]['distance']['value'] as int;
        remainingSeconds = totalDurationSeconds;
      }

      // Combine for full route polyline
      List<LatLng> fullPolyline = [...completedPoints, ...remainingPoints];
      int driverSplitIndex =
          completedPoints.isNotEmpty ? completedPoints.length - 1 : 0;
      double driverFraction = totalDurationSeconds > 0
          ? completedSeconds / totalDurationSeconds
          : 0;

      // Calculate cumulative distances along full polyline
      List<double> cumulativeDistances = [0.0];
      for (int i = 1; i < fullPolyline.length; i++) {
        double segDist =
            _haversineDistance(fullPolyline[i - 1], fullPolyline[i]);
        cumulativeDistances.add(cumulativeDistances.last + segDist);
      }
      double totalPolylineDist = cumulativeDistances.last;
      double driverDistanceOnRoute = driverSplitIndex < cumulativeDistances.length
          ? cumulativeDistances[driverSplitIndex]
          : 0;

      // Determine number of stops based on route distance (minimum 3)
      int numStops;
      if (totalDistanceMeters < 200000) {
        numStops = 3; // < 200 km — 3 stops
      } else if (totalDistanceMeters < 500000) {
        numStops = min(5, maxStops); // 200–500 km
      } else {
        numStops = maxStops; // 500+ km
      }

      // Sample evenly-spaced intermediate stops
      List<Map<String, dynamic>> stops = [];
      if (numStops > 0 && totalPolylineDist > 0) {
        double interval = totalPolylineDist / (numStops + 1);
        for (int i = 1; i <= numStops; i++) {
          double targetDist = interval * i;
          LatLng point = _interpolatePointOnPolyline(
              targetDist, fullPolyline, cumulativeDistances);
          double fraction = targetDist / totalPolylineDist;
          bool passed = targetDist <= driverDistanceOnRoute;
          stops.add({
            'location': point,
            'distance_fraction': fraction,
            'estimated_seconds': (totalDurationSeconds * fraction).round(),
            'passed': passed,
          });
        }

        // Reverse geocode all stops in parallel
        List<String?> names = await Future.wait(
          stops.map((s) => reverseGeocode(s['location'] as LatLng)),
        );
        for (int i = 0; i < stops.length; i++) {
          stops[i]['name'] = names[i] ?? 'Unknown';
        }

        // Remove all duplicate names (keep first occurrence)
        List<Map<String, dynamic>> uniqueStops = [];
        Set<String> seenNames = {};
        for (var stop in stops) {
          final name = stop['name'] as String;
          if (name != 'Unknown' && !seenNames.contains(name)) {
            uniqueStops.add(stop);
            seenNames.add(name);
          }
        }
        stops = uniqueStops;
      }

      return {
        'polyline_points': fullPolyline,
        'completed_points': completedPoints,
        'remaining_points': remainingPoints,
        'stops': stops,
        'total_duration_seconds': totalDurationSeconds,
        'total_distance_meters': totalDistanceMeters,
        'driver_split_index': driverSplitIndex,
        'driver_progress_fraction': driverFraction,
        'remaining_duration_seconds': remainingSeconds,
        'cumulative_distances': cumulativeDistances,
      };
    } catch (e) {
      debugPrint('Error getting route with stops: $e');
      return {};
    }
  }

  /// Generate sub-stops between two fractions along the route polyline.
  static Future<List<Map<String, dynamic>>> generateSubStops({
    required List<LatLng> fullPolyline,
    required List<double> cumulativeDistances,
    required double startFraction,
    required double endFraction,
    required int totalDurationSeconds,
    int count = 3,
  }) async {
    if (fullPolyline.isEmpty || cumulativeDistances.isEmpty) return [];

    final totalDist = cumulativeDistances.last;
    final startDist = totalDist * startFraction;
    final endDist = totalDist * endFraction;
    final segmentDist = endDist - startDist;
    if (segmentDist <= 0) return [];

    final interval = segmentDist / (count + 1);
    List<Map<String, dynamic>> subStops = [];

    for (int i = 1; i <= count; i++) {
      final targetDist = startDist + interval * i;
      final point = _interpolatePointOnPolyline(
        targetDist,
        fullPolyline,
        cumulativeDistances,
      );
      final fraction = targetDist / totalDist;
      subStops.add({
        'location': point,
        'estimated_seconds': (totalDurationSeconds * fraction).round(),
        'distance_fraction': fraction,
      });
    }

    // Reverse geocode all sub-stops in parallel
    final names = await Future.wait(
      subStops.map((s) => reverseGeocode(s['location'] as LatLng)),
    );
    for (int i = 0; i < subStops.length; i++) {
      subStops[i]['name'] = names[i] ?? 'Unknown';
    }

    // Remove duplicates and unknowns
    List<Map<String, dynamic>> unique = [];
    Set<String> seen = {};
    for (var stop in subStops) {
      final name = stop['name'] as String;
      if (name != 'Unknown' && !seen.contains(name)) {
        unique.add(stop);
        seen.add(name);
      }
    }

    return unique;
  }

  /// Decode polylines from all steps in a Directions API leg
  static List<LatLng> _decodeStepsPolyline(List steps) {
    List<LatLng> points = [];
    for (var step in steps) {
      final stepPoints =
          _decodePolyline(step['polyline']['points'] as String);
      if (points.isNotEmpty && stepPoints.isNotEmpty) {
        // Skip first point of subsequent steps to avoid duplicates
        points.addAll(stepPoints.sublist(1));
      } else {
        points.addAll(stepPoints);
      }
    }
    return points;
  }

  /// Find the index of the closest point on a polyline to the given position
  static int _findClosestPointIndex(List<LatLng> points, LatLng target) {
    int closestIdx = 0;
    double minDist = double.infinity;
    for (int i = 0; i < points.length; i++) {
      double dist = _haversineDistance(points[i], target);
      if (dist < minDist) {
        minDist = dist;
        closestIdx = i;
      }
    }
    return closestIdx;
  }

  /// Interpolate a point along the polyline at a given cumulative distance
  static LatLng _interpolatePointOnPolyline(
    double targetDist,
    List<LatLng> polylinePoints,
    List<double> cumulativeDistances,
  ) {
    for (int j = 1; j < cumulativeDistances.length; j++) {
      if (cumulativeDistances[j] >= targetDist) {
        double segStart = cumulativeDistances[j - 1];
        double segEnd = cumulativeDistances[j];
        double fraction =
            (segEnd - segStart) > 0 ? (targetDist - segStart) / (segEnd - segStart) : 0;
        return LatLng(
          polylinePoints[j - 1].latitude +
              (polylinePoints[j].latitude - polylinePoints[j - 1].latitude) *
                  fraction,
          polylinePoints[j - 1].longitude +
              (polylinePoints[j].longitude - polylinePoints[j - 1].longitude) *
                  fraction,
        );
      }
    }
    return polylinePoints.last;
  }

  /// Calculate haversine distance between two points in meters
  static double _haversineDistance(LatLng a, LatLng b) {
    const earthRadius = 6371000.0;
    double dLat = _toRadians(b.latitude - a.latitude);
    double dLng = _toRadians(b.longitude - a.longitude);
    double h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(a.latitude)) *
            cos(_toRadians(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * earthRadius * asin(sqrt(h));
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  /// Decode Google's encoded polyline algorithm
  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      // Decode latitude
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
