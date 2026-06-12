import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/scanner_provider.dart';
import 'routes/app_routes.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/qr_scanner_service.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.create();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>(
          create: (_) => AuthService(apiService, storageService),
        ),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<QrScannerService>(create: (_) => QrScannerService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<AuthService>())..restoreSession(),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (context) => HistoryProvider(storageService)..loadHistory(),
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          HistoryProvider,
          ScannerProvider
        >(
          create: (context) => ScannerProvider(
            apiService: context.read<ApiService>(),
            locationService: context.read<LocationService>(),
            qrScannerService: context.read<QrScannerService>(),
            historyProvider: context.read<HistoryProvider>(),
            storageService: context.read<StorageService>(),
          ),
          update: (context, auth, history, scanner) =>
              (scanner ??
                      ScannerProvider(
                        apiService: context.read<ApiService>(),
                        locationService: context.read<LocationService>(),
                        qrScannerService: context.read<QrScannerService>(),
                        historyProvider: history,
                        storageService: context.read<StorageService>(),
                      ))
                  .setEmployee(auth.employee),
        ),
      ],
      child: const QrAttendanceApp(),
    ),
  );
}

class QrAttendanceApp extends StatelessWidget {
  const QrAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Attendance Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
