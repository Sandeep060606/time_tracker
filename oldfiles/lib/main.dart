import 'dart:async';

import 'package:aditya_time_tracker/backend.dart';
import 'package:aditya_time_tracker/login.dart';
import 'package:aditya_time_tracker/scanner.dart';
import 'package:aditya_time_tracker/selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

Box<dynamic>? storage;
String status = "Login";
String accessCode = "";
Map<String, dynamic>? purpose;
String scannedData = "";
String campusPlaceholder = "";
String employeePlaceholder = "";
Color whitegrey = const Color.fromRGBO(176, 176, 176, 50);
String employeeCode = "";
String campusCode = "";
int count = 0;
bool warning = false;
Color countColor = Colors.white;
List registeredStudents = [];
List failedStudents = [];

///Change APIs Here///
///
///
///
String postLink = "https://w.aditya.ac.in/qrscanapi/scanIdCard/";
String purposeLink =
    "https://w.aditya.ac.in/qrscanapi/purpose/"; //Access Link Should End With "/"
String trackLink = "https://apis.aditya.ac.in/kafka/producer/bustracker";
////END HERE////
///
///
///
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  askPermissions();
  storage = await Hive.openBox("storage");
  if (await storage?.get("Status") != null) {
    status = await storage?.get("Status");
  } else {
    status = "Login";
  }
  warning = false;
  countColor = Colors.white;
  if (await storage?.get("Count") != null) {
    count = await storage?.get("Count");
  } else {
    await storage?.put("Count", 0);
    count = 0;
  }
  if (await storage?.get("RegisteredStudents") != null) {
    registeredStudents = await storage?.get("RegisteredStudents");
  } else {
    storage?.put("RegisteredStudents", []);
    registeredStudents = [];
  }

  if (await storage?.get("failed") != null) {
    failedStudents = await storage?.get("failed");
  } else {
    storage?.put("failed", []);
    failedStudents = [];
  }

  storage?.put("ScannedData", "");
  runApp(const Home());
}

Future<void> showToast(message, Color color) async {
  await Fluttertoast.showToast(
      msg: message.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.sp);
}

void askPermissions() async {
  List<Permission> permissions = [
    Permission.camera,
    Permission.location,
    Permission.locationWhenInUse
  ];
  for (var permission in permissions) {
    if (await permission.isDenied) {
      await permission.request();
    }
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
    final GoRouter navigation = GoRouter(
      routes: <GoRoute>[
        GoRoute(
          routes: <GoRoute>[
            GoRoute(
              path: 'login',
              name: "Login",
              builder: (BuildContext context, GoRouterState state) =>
                  const Login(),
            ),
            GoRoute(
              path: 'purpose',
              name: "Purpose",
              builder: (BuildContext context, GoRouterState state) =>
                  const PurposeSelections(),
            ),
            GoRoute(
              path: 'scanner',
              name: "Scanner",
              builder: (BuildContext context, GoRouterState state) =>
                  const Scanner(),
            ),
          ],
          path: '/',
          builder: (BuildContext context, GoRouterState state) => const Login(),
        ),
      ],
      redirect: (context, state) async {
        if (await storage?.get("Status") != null) {
          status = await storage?.get("Status");
        } else {
          status = "Login";
        }
        if (status == "Login") {
          return "/login";
        } else if (status == "Purpose") {
          return "/purpose";
        } else if (status == "Scanner") {
          return "/scanner";
        } else {
          return "/login";
        }
      },
    );
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return SafeArea(
          child: MaterialApp.router(
            routerDelegate: navigation.routerDelegate,
            routeInformationParser: navigation.routeInformationParser,
            routeInformationProvider: navigation.routeInformationProvider,
          ),
        );
      },
    );
  }
}

FlutterBackgroundService flutterBackgroundService = FlutterBackgroundService();

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance serviceInstance) async {
  serviceInstance.on("startTracking").listen((data) {
    try {
      if (data != null) {
        String employeeCode = data['employeeCode'];
        String campusCode = data['campusCode'];
        String purpose = data['purpose'];
        startTracking(
          employeeCode: employeeCode,
          campusCode: campusCode,
          purpose: purpose,
        );
      }
    } catch (error) {}
  });
  serviceInstance.on("stopTracking").listen((data) async {
    await serviceInstance.stopSelf();
  });
}

Future<void> startService({
  required String employeeCode,
  required String campusCode,
  required String purpose,
}) async {
  if (!(await flutterBackgroundService.isRunning())) {
    flutterBackgroundService.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          initialNotificationContent: "Tracking Location....",
          initialNotificationTitle: "Aditya Time Tracker Is Running...!"),
    );
    Future.delayed(Duration(seconds: 3)).then((value) {
      flutterBackgroundService.invoke("startTracking", {
        "employeeCode": employeeCode,
        "campusCode": campusCode,
        "purpose": purpose,
      });
    });
  }
}

Future<void> stopServie() async {
  try {
    if (await flutterBackgroundService.isRunning()) {
      flutterBackgroundService.invoke("stopTracking");
    }
  } catch (error) {}
}

void startTracking({
  required String employeeCode,
  required String campusCode,
  required String purpose,
}) {
  try {
    Timer.periodic(Duration(seconds: 10), (timer) async {
      try {
        await postLocation(
          employeeCode: employeeCode,
          campusCode: campusCode,
          purpose: purpose,
        );
      } catch (error) {}
    });
  } catch (error) {}
}
