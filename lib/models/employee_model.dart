class EmployeeModel {
  const EmployeeModel({
    required this.empStatus,
    required this.paycode,
    required this.empName,
    required this.employeeId,
    required this.designation,
    required this.departmentName,
    required this.campusName,
    required this.mobileNo,
    required this.accessLevel,
    required this.campusAddress,
  });

  final String empStatus;
  final String paycode;
  final String empName;
  final String employeeId;
  final String designation;
  final String departmentName;
  final String campusName;
  final String mobileNo;
  final String accessLevel;
  final String campusAddress;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empStatus: json['empStatus']?.toString() ?? '',
      paycode: json['paycode']?.toString() ?? '',
      empName: json['empName']?.toString().trim() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      departmentName: json['DepartmentName']?.toString() ?? '',
      campusName: json['campusName']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? '',
      accessLevel: json['accessLevel']?.toString() ?? '',
      campusAddress: json['campusAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empStatus': empStatus,
      'paycode': paycode,
      'empName': empName,
      'employeeId': employeeId,
      'designation': designation,
      'DepartmentName': departmentName,
      'campusName': campusName,
      'mobileNo': mobileNo,
      'accessLevel': accessLevel,
      'campusAddress': campusAddress,
    };
  }
}
