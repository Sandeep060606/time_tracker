class PurposeModel {
  const PurposeModel({
    required this.id,
    required this.purpose,
    required this.input1,
    required this.input2,
    required this.accesscode,
    required this.tracking,
  });

  final String id;
  final String purpose;
  final String input1;
  final String input2;
  final String accesscode;
  final bool tracking;

  factory PurposeModel.fromJson(Map<String, dynamic> json) {
    return PurposeModel(
      id: json['_id']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      input1: json['input1']?.toString() ?? '',
      input2: json['input2']?.toString() ?? '',
      accesscode: json['accesscode']?.toString() ?? '',
      tracking: json['tracking'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'purpose': purpose,
      'input1': input1,
      'input2': input2,
      'accesscode': accesscode,
      'tracking': tracking,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurposeModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          purpose == other.purpose;

  @override
  int get hashCode => id.hashCode ^ purpose.hashCode;
}
