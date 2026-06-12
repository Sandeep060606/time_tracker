import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/employee_model.dart';
import '../models/purpose_model.dart';
import '../models/qr_scan_request_model.dart';
import '../models/scan_history_model.dart';
import '../models/scan_result_model.dart';
import '../models/student_transport_model.dart';
import '../providers/history_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/qr_scanner_service.dart';
import '../services/storage_service.dart';
import '../utils/date_time_utils.dart';
import '../utils/validators.dart';

class ScannerProvider extends ChangeNotifier {
  ScannerProvider({
    required ApiService apiService,
    required LocationService locationService,
    required QrScannerService qrScannerService,
    required HistoryProvider historyProvider,
    required StorageService storageService,
  }) : _apiService = apiService,
       _locationService = locationService,
       _qrScannerService = qrScannerService,
       _historyProvider = historyProvider,
       _storageService = storageService {
    _loadSelectedPurpose();
  }

  final ApiService _apiService;
  final LocationService _locationService;
  final QrScannerService _qrScannerService;
  final HistoryProvider _historyProvider;
  final StorageService _storageService;

  EmployeeModel? _employee;
  PurposeModel? _selectedPurpose;
  String? _employeeCodeInput;
  String? _campusCodeInput;
  Timer? _trackingTimer;
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;
  PurposeModel? get selectedPurpose => _selectedPurpose;
  String? get employeeCodeInput => _employeeCodeInput;
  String? get campusCodeInput => _campusCodeInput;

  void _loadSelectedPurpose() {
    _selectedPurpose = _storageService.getSelectedPurpose();
    _employeeCodeInput = _storageService.getEmployeeCodeInput();
    _campusCodeInput = _storageService.getCampusCodeInput();
    if (_selectedPurpose != null && _selectedPurpose!.tracking) {
      _startTracking();
    }
  }

  void _startTracking() {
    if (_trackingTimer != null) return;
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final emp = _employeeCodeInput ?? _employee?.paycode;
      final campus = _campusCodeInput;
      final purpose = _selectedPurpose?.purpose;
      if (emp != null && campus != null && purpose != null) {
        try {
          final position = await _locationService.currentPosition();
          await _apiService.postLocation(
            employeeCode: emp,
            campusCode: campus,
            purpose: purpose,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        } catch (_) {
          // Silently ignore tracking errors in background
        }
      }
    });
  }

  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }

  void setSelectedPurpose(PurposeModel? purpose) {
    _stopTracking();
    _selectedPurpose = purpose;
    if (purpose != null) {
      _storageService.saveSelectedPurpose(purpose);
    } else {
      _employeeCodeInput = null;
      _campusCodeInput = null;
      _storageService.clearSelectedPurpose();
    }
    notifyListeners();
  }

  void setSelectedPurposeWithInputs(
    PurposeModel? purpose,
    String employeeCode,
    String campusCode,
  ) {
    _stopTracking();
    _selectedPurpose = purpose;
    _employeeCodeInput = employeeCode;
    _campusCodeInput = campusCode;
    if (purpose != null) {
      _storageService.saveSelectedPurpose(purpose);
      _storageService.saveSelectedPurposeInputs(employeeCode, campusCode);
      if (purpose.tracking) {
        _startTracking();
      }
    } else {
      _employeeCodeInput = null;
      _campusCodeInput = null;
      _storageService.clearSelectedPurpose();
    }
    notifyListeners();
  }

  ScannerProvider setEmployee(EmployeeModel? employee) {
    _employee = employee;
    return this;
  }

  Future<ScanResultModel> processScan(String rawCode) async {
    String studentID = rawCode.trim();
    if (studentID.length != 10) {
      try {
        final decoded = jsonDecode(studentID);
        if (decoded is Map<String, dynamic> &&
            decoded['SUC'] != null &&
            decoded['SUC'].toString().isNotEmpty) {
          studentID = decoded['SUC'].toString();
        }
      } catch (_) {
        // Keep raw code
      }
    }

    if (studentID.isEmpty) {
      throw const ScanException('Invalid Student ID in QR code.');
    }

    final employee = _employee;
    if (employee == null) {
      throw const ScanException('Please login again before scanning.');
    }
    if (_selectedPurpose == null) {
      throw const ScanException('Please select a purpose first.');
    }
    if (!Validators.isValidQr(studentID)) {
      throw const ScanException('Invalid Student ID in QR code.');
    }

    // Check session duplicates
    final alreadyScanned = _historyProvider.history.any(
      (item) =>
          item.studentQr == studentID &&
          item.status == ScanStatus.success &&
          DateTimeUtils.isSameDate(item.time, DateTime.now()),
    );
    if (alreadyScanned) {
      throw const ScanException('Student already scanned today.');
    }

    if (_qrScannerService.isDuplicate(studentID)) {
      throw const ScanException('Duplicate scan ignored. Try after 3 seconds.');
    }

    _isProcessing = true;
    notifyListeners();

    String? latitude;
    String? longitude;
    final now = DateTime.now();
    final purposeName = _selectedPurpose!.purpose;
    final emp = _employeeCodeInput ?? employee.paycode;
    final campus = _campusCodeInput ?? '';

    try {
      try {
        final position = await _locationService.currentPosition();
        latitude = position.latitude.toStringAsFixed(6);
        longitude = position.longitude.toStringAsFixed(6);
      } catch (_) {
        // Allow scanning even if location fetching fails
      }

      final request = QrScanRequestModel(
        purpose: purposeName,
        scannedAt: campus,
        empCode: emp,
        suc: studentID,
        timestamp: DateTimeUtils.formatForApi(now),
        longitude: longitude ?? '0.0',
        latitude: latitude ?? '0.0',
      );

      final response = await _apiService.postQrScan(request);
      StudentTransportModel? student;
      try {
        student = await _apiService.fetchStudentTransportInfo(studentID);
      } catch (_) {
        student = null;
      }
      final responseData = response.value.data;
      final history = ScanHistoryModel(
        id: responseData.id.isNotEmpty
            ? responseData.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        studentQr: studentID,
        time: now,
        purpose: purposeName,
        status: ScanStatus.success,
        employeeCode: emp,
        student: student,
        latitude: latitude,
        longitude: longitude,
        transactionId: responseData.id,
      );

      await _historyProvider.add(history);
      await _qrScannerService.successFeedback();

      return ScanResultModel(
        response: response,
        history: history,
        student: student,
      );
    } catch (error) {
      final failure = ScanHistoryModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        studentQr: studentID,
        time: now,
        purpose: purposeName,
        status: ScanStatus.failed,
        employeeCode: emp,
        failureReason: error.toString(),
        latitude: latitude,
        longitude: longitude,
      );
      await _historyProvider.add(failure);
      throw ScanException(error.toString());
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }
}

class ScanException implements Exception {
  const ScanException(this.message);

  final String message;

  @override
  String toString() => message;
}
