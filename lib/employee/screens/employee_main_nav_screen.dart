import 'package:bestseeds/employee/controllers/notification_controller.dart';
import 'package:bestseeds/employee/screens/booking_screen.dart';
import 'package:bestseeds/employee/screens/custom_bottom_nav_bar.dart';
import 'package:bestseeds/employee/screens/employee_home_screen.dart';
import 'package:bestseeds/employee/screens/profile_screen.dart';
import 'package:bestseeds/employee/screens/tracking_screen.dart';
import 'package:bestseeds/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Controller for managing bottom navigation state
class EmployeeNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToBookings() => changeTab(1);
  void goToTracking() => changeTab(2);
  void goToProfile() => changeTab(3);
  void goToHome() => changeTab(0);
}

class EmployeeMainNavigationScreen extends StatefulWidget {
  const EmployeeMainNavigationScreen({super.key});

  @override
  State<EmployeeMainNavigationScreen> createState() =>
      _EmployeeMainNavigationScreenState();
}

class _EmployeeMainNavigationScreenState
    extends State<EmployeeMainNavigationScreen> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(EmployeeNavController());
    Get.put(EmployeeNotificationController());

    final List<Widget> screens = [
      const EmployeeDashboard(),
      const BookingScreen(),
      const TrackingScreen(),
      EmployeeProfileScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (navController.currentIndex.value != 0) {
          navController.goToHome();
        } else {
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
        body: Obx(() => IndexedStack(
              index: navController.currentIndex.value,
              children: screens,
            )),
        bottomNavigationBar: Obx(() => EmployeeBottomNavBar(
              currentIndex: navController.currentIndex.value,
              onTap: navController.changeTab,
            )),
      ),
    );
  }
}
