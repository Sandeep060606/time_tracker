import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/login_response_model.dart';
import '../models/purpose_model.dart';
import '../models/qr_scan_request_model.dart';
import '../models/scan_response_model.dart';
import '../models/student_transport_model.dart';
import '../utils/app_constants.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 20);

  Future<LoginResponseModel> verifyLogin({
    required String paycode,
    required String password,
  }) async {
    final response = await _postJson(Uri.parse(AppConstants.loginUrl), {
      'paycode': paycode,
      'pwd': password,
    });
    final loginResponse = LoginResponseModel.fromJson(response);
    if (loginResponse.status != 200 || loginResponse.data.isEmpty) {
      throw const ApiException('Invalid username or password.');
    }
    if (loginResponse.data.first.empStatus.toLowerCase() != 'working') {
      throw const ApiException('Employee account is not active.');
    }
    return loginResponse;
  }

  Future<List<PurposeModel>> fetchPurposes() async {
    final uri = Uri.parse(AppConstants.purposeUrl);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Failed to load purposes (${response.statusCode}).');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const ApiException('Invalid response format.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PurposeModel.fromJson)
          .toList();
    } on TimeoutException {
      throw const ApiException('Purposes request timed out.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on FormatException {
      throw const ApiException('Invalid data returned for purposes.');
    }
  }

  Future<ScanResponseModel> postQrScan(QrScanRequestModel request) async {
    final response = await _postJson(
      Uri.parse(AppConstants.scanPostUrl),
      request.toJson(),
    );
    if (response.containsKey('value')) {
      return ScanResponseModel.fromJson(response);
    }
    return ScanResponseModel(
      timestamp: [],
      topic: '',
      value: ScanValueModel(
        data: ScanResponseDataModel(
          purpose: request.purpose,
          scannedAt: request.scannedAt,
          empCode: request.empCode,
          suc: request.suc,
          timestamp: request.timestamp,
          longitude: request.longitude,
          latitude: request.latitude,
          id: DateTime.now().microsecondsSinceEpoch.toString(),
        ),
      ),
    );
  }

  Future<void> postLocation({
    required String employeeCode,
    required String campusCode,
    required String purpose,
    required double? latitude,
    required double? longitude,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> locationData = {
      "accuracy": 0.0,
      "log": longitude ?? 0.0,
      "lat": latitude ?? 0.0,
      "speed": 0.0,
      "heading": 0.0,
      "speedAccuracy": 0.0,
    };
    final Map<String, dynamic> body = {
      "purpose": purpose,
      "scannedat": campusCode,
      "empcode": employeeCode,
      "timestamp": now,
    };
    body.addAll(locationData);
    final Map<String, dynamic> data = {"data": body};
    await _postJson(Uri.parse(AppConstants.trackUrl), data);
  }

  Future<StudentTransportModel?> fetchStudentTransportInfo(String suc) async {
    final uri = Uri.parse('${AppConstants.studentInfoBaseUrl}/$suc');
    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Origin': AppConstants.analysisOrigin,
              'Referer': AppConstants.studentInfoReferer,
            },
          )
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Student lookup failed (${response.statusCode}).');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final studentList = body['studentinfo'];
      if (studentList is! List || studentList.isEmpty) {
        return null;
      }
      return StudentTransportModel.fromApiJson(body);
    } on TimeoutException {
      throw const ApiException('Student lookup timed out.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on FormatException {
      throw const ApiException('Student lookup returned invalid data.');
    }
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Server returned ${response.statusCode}.');
      }

      final bodyStr = response.body.trim();
      if (bodyStr.isEmpty) {
        return const {};
      }
      try {
        final decoded = jsonDecode(bodyStr);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'status': decoded};
      } catch (_) {
        return {'status': bodyStr};
      }
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on SocketException {
      throw const ApiException('No internet connection.');
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
