import 'dart:convert';
import 'package:bestseeds/driver/models/driver_booking_model.dart';
import 'package:bestseeds/utils/database_helper.dart';

class DriverBookingCacheService {
  final DatabaseHelper _db = DatabaseHelper();

  static const _cacheKey = 'driver_bookings';

  Future<void> cacheBookings(Map<String, dynamic> responseJson) async {
    await _db.saveCache(_cacheKey, jsonEncode(responseJson));
  }

  Future<DriverBookingResponse?> getCachedBookings() async {
    final json = await _db.getCache(_cacheKey);
    if (json == null) return null;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return DriverBookingResponse.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _db.clearByPrefix('driver_');
  }
}
