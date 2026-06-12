import 'dart:io';
import 'package:aditya_time_tracker/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

final dio = Dio();

Future<Map<String, dynamic>?> login(String code) async {
  var response = await dio.get("$purposeLink$code");
  try {
    var body = response.data as List;
    if (body.isNotEmpty) {
      var data = body[0];
      if (code == data["accesscode"]) {
        await storage?.put("accesscode", code);
        return data;
      }
    }
  } catch (expect) {}
  return null;
}

Future<String> submitPurpose(
  String employee,
  String campus,
  String purpose,
) async {
  if (purpose != "Select Purpose") {
    await storage?.put("employeeCode", employee);
    await storage?.put("campusCode", campus);
    await storage?.put("purpose", purpose);
    return "Scanner";
  } else {
    return "Invalid Code";
  }
}

Future<Map<String, dynamic>> locate() async {
  Map<String, dynamic> locationJson = {};
  try {
    if (await Geolocator.isLocationServiceEnabled()) {
      var permissonStatus = await Geolocator.checkPermission();
      if (permissonStatus == LocationPermission.denied ||
          permissonStatus == LocationPermission.deniedForever) {
        showToast("Please Grant Location Permission", Colors.redAccent);
        Geolocator.requestPermission();
      } else {
        Position location = await Geolocator.getCurrentPosition();
        locationJson = {
          "accuracy": location.accuracy,
          "log": location.longitude,
          "lat": location.latitude,
          "speed": location.speed,
          "heading": location.heading,
          "speedAccuracy": location.speedAccuracy,
        };
      }
    } else {
      showToast("Please Enable Location Service", Colors.redAccent);
    }
  } catch (e) {}
  return locationJson;
}

Future<bool> postFailed(Map<dynamic, dynamic> data) async {
  try {
    await dio.post(postLink, data: data);
    return true;
  } catch (expect) {}
  return false;
}

Future<void> postMan(String studentData) async {
  try {
    Map<String, dynamic> location = await locate();
    employeeCode = storage?.get("employeeCode");
    var timeStamp = DateTime.now().millisecondsSinceEpoch;
    var data = {
      "data": {
        "purpose": purpose!['purpose'],
        "scannedat": campusCode,
        "empcode": employeeCode,
        "suc": studentData,
        "timestamp": timeStamp,
        "log": location['log'],
        "lat": location['lat'],
      },
    };
    try {
      await dio.post(postLink, data: data);
    } catch (expect) {
      failedStudents.add(data);
      await storage?.put("failed", failedStudents);
    }
  } catch (error) {}
}

Future<void> postLocation({
  required String employeeCode,
  required String campusCode,
  required String purpose,
}) async {
  Map<String, dynamic> location = await locate();
  var timeStamp = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic> body = {
    "purpose": purpose,
    "scannedat": campusCode,
    "empcode": employeeCode,
    "timestamp": timeStamp,
  };
  body.addAll(location);
  Map<String, dynamic> data = {"data": body};
  try {
    await dio.post(trackLink, data: data);
  } catch (error) {
    print(error);
  }
}

Future<bool> checkInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {}
  return false;
}
