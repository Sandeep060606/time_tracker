import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/scanner_provider.dart';
import '../routes/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoading && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            final hasPurpose =
                context.read<ScannerProvider>().selectedPurpose != null;
            Navigator.of(context).pushReplacementNamed(
              auth.isAuthenticated
                  ? (hasPurpose ? AppRoutes.home : AppRoutes.selectPurpose)
                  : AppRoutes.login,
            );
          });
        }

        return const Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primary,
                  AppTheme.accent,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppLogo(),
                  SizedBox(height: 28),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
