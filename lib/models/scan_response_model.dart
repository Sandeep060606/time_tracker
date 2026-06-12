class ScanResponseModel {
  const ScanResponseModel({
    required this.timestamp,
    required this.topic,
    required this.value,
  });

  final List<dynamic> timestamp;
  final String topic;
  final ScanValueModel value;

  factory ScanResponseModel.fromJson(Map<String, dynamic> json) {
    return ScanResponseModel(
      timestamp: json['timestamp'] is List
          ? List<dynamic>.from(json['timestamp'] as List)
          : const [],
      topic: json['topic']?.toString() ?? '',
      value: ScanValueModel.fromJson(
        json['value'] is Map<String, dynamic>
            ? json['value'] as Map<String, dynamic>
            : const {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp, 'topic': topic, 'value': value.toJson()};
  }
}

class ScanValueModel {
  const ScanValueModel({required this.data});

  final ScanResponseDataModel data;

  factory ScanValueModel.fromJson(Map<String, dynamic> json) {
    return ScanValueModel(
      data: ScanResponseDataModel.fromJson(
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {'data': data.toJson()};
}

class ScanResponseDataModel {
  const ScanResponseDataModel({
    required this.purpose,
    required this.scannedAt,
    required this.empCode,
    required this.suc,
    required this.timestamp,
    required this.longitude,
    required this.latitude,
    required this.id,
  });

  final String purpose;
  final String scannedAt;
  final String empCode;
  final String suc;
  final String timestamp;
  final String longitude;
  final String latitude;
  final String id;

  factory ScanResponseDataModel.fromJson(Map<String, dynamic> json) {
    return ScanResponseDataModel(
      purpose: json['purpose']?.toString() ?? '',
      scannedAt: json['scannedat']?.toString() ?? '',
      empCode: json['empcode']?.toString() ?? '',
      suc: json['suc']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
      longitude: json['log']?.toString() ?? '',
      latitude: json['lat']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purpose': purpose,
      'scannedat': scannedAt,
      'empcode': empCode,
      'suc': suc,
      'timestamp': timestamp,
      'log': longitude,
      'lat': latitude,
      'id': id,
    };
  }
}
