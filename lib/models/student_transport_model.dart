class StudentTransportModel {
  const StudentTransportModel({
    required this.suc,
    required this.studentId,
    required this.name,
    required this.section,
    required this.rollNo,
    required this.className,
    required this.hasBus,
    required this.hasHostel,
    required this.feeDue,
    required this.termDues,
  });

  final String suc;
  final String studentId;
  final String name;
  final String section;
  final String rollNo;
  final String className;
  final bool hasBus;
  final bool hasHostel;
  final num feeDue;
  final List<TermDueModel> termDues;

  String get photoUrl =>
      'https://analysis.aditya.ac.in/uploads/student_photos/$studentId.jpg';

  factory StudentTransportModel.fromApiJson(Map<String, dynamic> json) {
    final studentList = json['studentinfo'];
    final feeList = json['feeinfo'];
    final student = studentList is List && studentList.isNotEmpty
        ? studentList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final dues = feeList is List
        ? feeList
              .whereType<Map<String, dynamic>>()
              .map(TermDueModel.fromJson)
              .toList()
        : <TermDueModel>[];

    return StudentTransportModel(
      suc: student['student_no']?.toString() ?? '',
      studentId: student['std_id']?.toString() ?? '',
      name: student['student_name']?.toString() ?? '',
      section: student['section_name']?.toString() ?? '',
      rollNo: student['roll_no']?.toString() ?? '',
      className: student['course_name']?.toString() ?? '',
      hasBus: student['bus']?.toString() == '1',
      hasHostel: student['hostel']?.toString() == '1',
      feeDue: dues.fold<num>(0, (sum, due) => sum + due.amountDue),
      termDues: dues,
    );
  }

  factory StudentTransportModel.fromJson(Map<String, dynamic> json) {
    return StudentTransportModel(
      suc: json['suc']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      rollNo: json['rollNo']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      hasBus: json['hasBus'] == true,
      hasHostel: json['hasHostel'] == true,
      feeDue: num.tryParse(json['feeDue']?.toString() ?? '') ?? 0,
      termDues: json['termDues'] is List
          ? (json['termDues'] as List)
                .whereType<Map<String, dynamic>>()
                .map(TermDueModel.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suc': suc,
      'studentId': studentId,
      'name': name,
      'section': section,
      'rollNo': rollNo,
      'className': className,
      'hasBus': hasBus,
      'hasHostel': hasHostel,
      'feeDue': feeDue,
      'termDues': termDues.map((term) => term.toJson()).toList(),
    };
  }
}

class TermDueModel {
  const TermDueModel({
    required this.termNumber,
    required this.dueDate,
    required this.amountDue,
  });

  final String termNumber;
  final DateTime? dueDate;
  final num amountDue;

  factory TermDueModel.fromJson(Map<String, dynamic> json) {
    return TermDueModel(
      termNumber:
          json['term_number']?.toString() ??
          json['termNumber']?.toString() ??
          '',
      dueDate: DateTime.tryParse(
        json['term_duedate']?.toString() ?? json['dueDate']?.toString() ?? '',
      ),
      amountDue:
          num.tryParse(
            json['term_due_amount']?.toString() ??
                json['amountDue']?.toString() ??
                '',
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'termNumber': termNumber,
      'dueDate': dueDate?.toIso8601String(),
      'amountDue': amountDue,
    };
  }
}
