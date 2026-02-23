import 'dart:convert';
import 'package:bestseeds/employee/models/booking_model.dart';
import 'package:bestseeds/utils/database_helper.dart';

class EmployeeBookingCacheService {
  final DatabaseHelper _db = DatabaseHelper();

  String _cacheKey(String? tab) {
    final tabName = tab ?? 'all';
    return 'employee_$tabName';
  }

  Future<void> cacheBookings(String? tab, Map<String, dynamic> responseJson) async {
    await _db.saveCache(_cacheKey(tab), jsonEncode(responseJson));
  }

  Future<BookingsResponse?> getCachedBookings(String? tab) async {
    final json = await _db.getCache(_cacheKey(tab));
    if (json == null) return null;
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return BookingsResponse.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAll() async {
    await _db.clearByPrefix('employee_');
  }
}
