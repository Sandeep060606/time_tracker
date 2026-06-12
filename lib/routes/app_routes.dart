import 'package:flutter/material.dart';

import '../models/scan_result_model.dart';
import '../screens/home_shell_screen.dart';
import '../screens/login_screen.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/select_purpose_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/student_details_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const selectPurpose = '/select-purpose';
  static const home = '/home';
  static const scanner = '/scanner';
  static const studentDetails = '/student-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        switch (settings.name) {
          case splash:
            return const SplashScreen();
          case login:
            return const LoginScreen();
          case selectPurpose:
            return const SelectPurposeScreen();
          case home:
            return const HomeShellScreen();
          case scanner:
            return const QrScannerScreen();
          case studentDetails:
            final result = settings.arguments;
            if (result is ScanResultModel) {
              return StudentDetailsScreen(result: result);
            }
            return const _RouteErrorScreen(
              message: 'Scan details were not available.',
            );
          default:
            return const _RouteErrorScreen(message: 'Page not found.');
        }
      },
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Attendance Scanner')),
      body: Center(child: Text(message)),
    );
  }
}
