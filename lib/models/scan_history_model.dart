import 'student_transport_model.dart';

class ScanHistoryModel {
  const ScanHistoryModel({
    required this.id,
    required this.studentQr,
    required this.time,
    required this.purpose,
    required this.status,
    required this.employeeCode,
    this.student,
    this.failureReason,
    this.latitude,
    this.longitude,
    this.transactionId,
  });

  final String id;
  final String studentQr;
  final DateTime time;
  final String purpose;
  final ScanStatus status;
  final String employeeCode;
  final StudentTransportModel? student;
  final String? failureReason;
  final String? latitude;
  final String? longitude;
  final String? transactionId;

  bool get isSuccess => status == ScanStatus.success;

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id']?.toString() ?? '',
      studentQr: json['studentQr']?.toString() ?? '',
      time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(),
      purpose: json['purpose']?.toString() ?? 'Transport',
      status: ScanStatus.values.firstWhere(
        (item) => item.name == json['status']?.toString(),
        orElse: () => ScanStatus.failed,
      ),
      employeeCode: json['employeeCode']?.toString() ?? '',
      student: json['student'] is Map<String, dynamic>
          ? StudentTransportModel.fromJson(
              json['student'] as Map<String, dynamic>,
            )
          : null,
      failureReason: json['failureReason']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      transactionId: json['transactionId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentQr': studentQr,
      'time': time.toIso8601String(),
      'purpose': purpose,
      'status': status.name,
      'employeeCode': employeeCode,
      'student': student?.toJson(),
      'failureReason': failureReason,
      'latitude': latitude,
      'longitude': longitude,
      'transactionId': transactionId,
    };
  }
}

enum ScanStatus { success, failed }
