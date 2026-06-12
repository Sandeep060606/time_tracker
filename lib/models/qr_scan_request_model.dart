class QrScanRequestModel {
  const QrScanRequestModel({
    required this.purpose,
    required this.scannedAt,
    required this.empCode,
    required this.suc,
    required this.timestamp,
    required this.longitude,
    required this.latitude,
  });

  final String purpose;
  final String scannedAt;
  final String empCode;
  final String suc;
  final String timestamp;
  final String longitude;
  final String latitude;

  factory QrScanRequestModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return QrScanRequestModel(
      purpose: data['purpose']?.toString() ?? '',
      scannedAt: data['scannedat']?.toString() ?? '',
      empCode: data['empcode']?.toString() ?? '',
      suc: data['suc']?.toString() ?? '',
      timestamp: data['timestamp']?.toString() ?? '',
      longitude: data['log']?.toString() ?? '',
      latitude: data['lat']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'purpose': purpose,
        'scannedat': scannedAt,
        'empcode': empCode,
        'suc': suc,
        'timestamp': timestamp,
        'log': longitude,
        'lat': latitude,
      },
    };
  }
}
