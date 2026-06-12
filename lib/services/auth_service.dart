import '../models/employee_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  const AuthService(this._apiService, this._storageService);

  final ApiService _apiService;
  final StorageService _storageService;

  Future<EmployeeModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.verifyLogin(
      paycode: username.trim(),
      password: password.trim(),
    );
    final employee = response.data.first;
    await _storageService.saveEmployee(employee);
    return employee;
  }

  EmployeeModel? currentEmployee() => _storageService.getEmployee();

  Future<void> logout() => _storageService.clearSession();
}
