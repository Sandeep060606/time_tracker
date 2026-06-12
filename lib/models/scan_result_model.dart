import 'scan_history_model.dart';
import 'scan_response_model.dart';
import 'student_transport_model.dart';

class ScanResultModel {
  const ScanResultModel({
    required this.response,
    required this.history,
    this.student,
  });

  final ScanResponseModel response;
  final ScanHistoryModel history;
  final StudentTransportModel? student;
}
