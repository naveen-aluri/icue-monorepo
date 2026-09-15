class ExamStudent {
  ExamStudent({
    required this.studentId,
    required this.name,
    this.classId,
    this.rollNo,
    this.section,
    this.admissionNumber,
    this.marks,
    this.status = 'PRESENT',
    this.remarks,
    this.isSaved = false,
  });

  factory ExamStudent.fromJson(Map<String, dynamic> json) => ExamStudent(
    studentId: json['StudentId'] is int
        ? json['StudentId']
        : json['Id'] is int
        ? json['Id']
        : int.tryParse(
                json['StudentId']?.toString() ?? json['Id']?.toString() ?? '',
              ) ??
              0,
    classId: json['ClassId'] is int
        ? json['ClassId']
        : int.tryParse(json['ClassId']?.toString() ?? ''),
    name: json['Name']?.toString() ?? json['StudentName']?.toString() ?? '',
    rollNo: json['RollNo']?.toString(),
    section: json['Section']?.toString(),
    admissionNumber:
        json['AdmissionNumber']?.toString() ?? json['AdmissionNo']?.toString(),
    marks: json['Marks'] is num
        ? json['Marks']
        : num.tryParse(json['Marks']?.toString() ?? ''),
    status: json['Status']?.toString().toUpperCase() ?? 'PRESENT',
    remarks: json['Remarks']?.toString(),
    isSaved: json['Marks'] != null ||
        json['Status'] != null ||
        (json['Remarks'] != null && json['Remarks'].toString().isNotEmpty),
  );

  final int studentId;
  final int? classId;
  final String name;
  final String? rollNo;
  final String? section;
  final String? admissionNumber;
  num? marks;
  String status; // 'PRESENT', 'ABSENT', 'NA'
  String? remarks;
  bool isSaved;

  ExamStudent copyWith({
    int? studentId,
    int? classId,
    String? name,
    String? rollNo,
    String? section,
    String? admissionNumber,
    num? marks,
    String? status,
    String? remarks,
    bool? isSaved,
  }) => ExamStudent(
    studentId: studentId ?? this.studentId,
    classId: classId ?? this.classId,
    name: name ?? this.name,
    rollNo: rollNo ?? this.rollNo,
    section: section ?? this.section,
    admissionNumber: admissionNumber ?? this.admissionNumber,
    marks: marks ?? this.marks,
    status: status ?? this.status,
    remarks: remarks ?? this.remarks,
    isSaved: isSaved ?? this.isSaved,
  );

  Map<String, dynamic> toJson() => {
    'StudentId': studentId,
    if (classId != null) 'ClassId': classId,
    'Name': name,
    if (rollNo != null) 'RollNo': rollNo,
    if (section != null) 'Section': section,
    if (admissionNumber != null) 'AdmissionNumber': admissionNumber,
    if (marks != null) 'Marks': marks,
    'Status': status,
    if (remarks != null) 'Remarks': remarks,
  };
}

class ExamMarksEntry {
  ExamMarksEntry({required this.studentId, this.marks, this.status});

  factory ExamMarksEntry.fromJson(Map<String, dynamic> json) => ExamMarksEntry(
    studentId: json['StudentId'] is int
        ? json['StudentId']
        : int.tryParse(json['StudentId']?.toString() ?? '') ?? 0,
    marks: json['Marks'] is num
        ? json['Marks']
        : num.tryParse(json['Marks']?.toString() ?? ''),
    status: json['Status']?.toString(),
  );

  final int studentId;
  final num? marks;
  final String? status; // 'PRESENT', 'ABSENT', 'NA'

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'StudentId': studentId};
    if (status != null && status != 'PRESENT') {
      map['Status'] = status;
    } else if (marks != null) {
      map['Marks'] = marks;
    } else if (status != null) {
      map['Status'] = status;
    }
    return map;
  }
}
