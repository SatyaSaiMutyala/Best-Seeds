import 'package:bestseeds/screens/login_screens/employee_login_screen.dart';
import 'package:flutter/material.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/login_screens/login_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String employeeLogin = '/employeeLogin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const DriverLoginScreen());
       case employeeLogin:
       return MaterialPageRoute(builder: (_) => const EmployeeLoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
