import 'employee_model.dart';

class LoginResponseModel {
  const LoginResponseModel({required this.status, required this.data});

  final int status;
  final List<EmployeeModel> data;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return LoginResponseModel(
      status: int.tryParse(json['status']?.toString() ?? '') ?? 0,
      data: rawData is List
          ? rawData
                .whereType<Map<String, dynamic>>()
                .map(EmployeeModel.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((employee) => employee.toJson()).toList(),
    };
  }
}
