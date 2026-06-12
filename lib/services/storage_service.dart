import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee_model.dart';
import '../models/purpose_model.dart';
import '../models/scan_history_model.dart';

class StorageService {
  const StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static const _employeeKey = 'logged_in_employee';
  static const _historyKey = 'scan_history';
  static const _selectedPurposeKey = 'selected_purpose';
  static const _employeeCodeInputKey = 'selected_purpose_employee_code';
  static const _campusCodeInputKey = 'selected_purpose_campus_code';

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  Future<void> saveEmployee(EmployeeModel employee) async {
    await _prefs.setString(_employeeKey, jsonEncode(employee.toJson()));
  }

  EmployeeModel? getEmployee() {
    final raw = _prefs.getString(_employeeKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return EmployeeModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_employeeKey);
    await _prefs.remove(_selectedPurposeKey);
    await _prefs.remove(_employeeCodeInputKey);
    await _prefs.remove(_campusCodeInputKey);
  }

  Future<void> saveSelectedPurposeInputs(
    String empCode,
    String campusCode,
  ) async {
    await _prefs.setString(_employeeCodeInputKey, empCode);
    await _prefs.setString(_campusCodeInputKey, campusCode);
  }

  String? getEmployeeCodeInput() {
    return _prefs.getString(_employeeCodeInputKey);
  }

  String? getCampusCodeInput() {
    return _prefs.getString(_campusCodeInputKey);
  }

  Future<void> clearSelectedPurposeInputs() async {
    await _prefs.remove(_employeeCodeInputKey);
    await _prefs.remove(_campusCodeInputKey);
  }

  Future<void> saveSelectedPurpose(PurposeModel purpose) async {
    await _prefs.setString(_selectedPurposeKey, jsonEncode(purpose.toJson()));
  }

  PurposeModel? getSelectedPurpose() {
    final raw = _prefs.getString(_selectedPurposeKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return PurposeModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSelectedPurpose() async {
    await _prefs.remove(_selectedPurposeKey);
    await _prefs.remove(_employeeCodeInputKey);
    await _prefs.remove(_campusCodeInputKey);
  }

  Future<void> saveHistory(List<ScanHistoryModel> history) async {
    final encoded = history.map((item) => item.toJson()).toList();
    await _prefs.setString(_historyKey, jsonEncode(encoded));
  }

  List<ScanHistoryModel> loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ScanHistoryModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> clearHistory() => _prefs.remove(_historyKey);
}
