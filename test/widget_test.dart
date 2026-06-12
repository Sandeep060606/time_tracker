import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracker/main.dart';
import 'package:time_tracker/providers/auth_provider.dart';
import 'package:time_tracker/providers/history_provider.dart';
import 'package:time_tracker/providers/navigation_provider.dart';
import 'package:time_tracker/providers/scanner_provider.dart';
import 'package:time_tracker/services/api_service.dart';
import 'package:time_tracker/services/auth_service.dart';
import 'package:time_tracker/services/location_service.dart';
import 'package:time_tracker/services/qr_scanner_service.dart';
import 'package:time_tracker/services/storage_service.dart';

void main() {
  testWidgets('shows login screen when no session is stored', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final storageService = await StorageService.create();
    final apiService = ApiService();

    await tester.pumpWidget(
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
            create: (_) => HistoryProvider(storageService)..loadHistory(),
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

    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
  });
}
