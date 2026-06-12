import 'package:flutter/foundation.dart';

import '../models/employee_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  EmployeeModel? _employee;
  bool _isLoading = true;
  String? _error;

  EmployeeModel? get employee => _employee;
  bool get isAuthenticated => _employee != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();
    _employee = _authService.currentEmployee();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _employee = await _authService.login(
        username: username,
        password: password,
      );
      return true;
    } catch (error) {
      _error = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _employee = null;
    notifyListeners();
  }
}
