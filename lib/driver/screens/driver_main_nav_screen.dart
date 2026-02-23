import 'package:bestseeds/driver/screens/booking_screen.dart';
import 'package:bestseeds/driver/screens/driver_home_screen.dart';
import 'package:bestseeds/driver/screens/profile_screen.dart';
import 'package:bestseeds/driver/screens/tracking_screen.dart';
import 'package:bestseeds/driver/services/background_location_service.dart';
import 'package:bestseeds/employee/screens/custom_bottom_nav_bar.dart';
import 'package:bestseeds/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverMainNavigationScreen extends StatefulWidget {
  const DriverMainNavigationScreen({super.key});

  @override
  State<DriverMainNavigationScreen> createState() =>
      _DriverMainNavigationScreenState();
}

class _DriverMainNavigationScreenState
    extends State<DriverMainNavigationScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  final List<Widget> _screens = [
    const DriverDashboard(),
    const BookingScreen(),
    const TrackingScreen(),
    DriverProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          // Block exit while a delivery journey is active
          final journeyActive = await BackgroundLocationService.isRunning();
          if (journeyActive) {
            toast('Cannot exit during an active delivery journey');
            return;
          }

          final now = DateTime.now();
          if (_lastBackPressed != null &&
              now.difference(_lastBackPressed!) < const Duration(seconds: 2)) {
            SystemNavigator.pop();
          } else {
            _lastBackPressed = now;
            toast('Press back again to exit');
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: EmployeeBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

