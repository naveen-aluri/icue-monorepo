// To parse this JSON data, do
//
//     final createAttendance = createAttendanceFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
part 'create_attendance.g.dart';

CreateAttendance createAttendanceFromJson(String str) =>
    CreateAttendance.fromJson(json.decode(str));

String createAttendanceToJson(CreateAttendance data) =>
    json.encode(data.toJson());

@HiveType(typeId: 12)
class CreateAttendance {
  CreateAttendance({
    required this.source,
    required this.students,
    required this.classId,
    required this.section,
    required this.standard,
    required this.attendanceDate,
    required this.attendanceTime,
    required this.month,
    required this.year,
    required this.period,
    this.attendanceMode,
  });

  factory CreateAttendance.fromJson(Map<String, dynamic> json) =>
      CreateAttendance(
        source: json['Source'],
        students: List<AttendanceStudent>.from(
          json['Students'].map((x) => AttendanceStudent.fromJson(x)),
        ),
        classId: json['ClassId'],
        section: json['Section'],
        standard: json['Standard'],
        attendanceDate: json['AttendanceDate'],
        attendanceTime: json['AttendanceTime'],
        month: json['Month'],
        year: json['Year'],
        period: json['Period'],
        attendanceMode: json['AttendanceMode'],
      );

  @HiveField(0)
  final String attendanceDate;

  @HiveField(1)
  final String attendanceTime;

  @HiveField(2)
  final int classId;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final String period;

  @HiveField(5)
  final String section;

  @HiveField(6)
  final String source;

  @HiveField(7)
  final String standard;

  @HiveField(8)
  final List<AttendanceStudent> students;

  @HiveField(9)
  final int year;

  @HiveField(10)
  final String? attendanceMode;

  Map<String, dynamic> toJson() => {
    'Source': source,
    'Students': List<dynamic>.from(students.map((x) => x.toJson())),
    'ClassId': classId,
    'Section': section,
    'Standard': standard,
    'AttendanceDate': attendanceDate,
    'AttendanceTime': attendanceTime,
    'Month': month,
    'Year': year,
    'Period': period,
    'AttendanceMode': attendanceMode,
  };

  CreateAttendance copyWith({
    String? source,
    List<AttendanceStudent>? students,
    int? classId,
    String? section,
    String? standard,
    String? attendanceDate,
    String? attendanceTime,
    int? month,
    int? year,
    String? period,
    String? attendanceMode,
  }) {
    return CreateAttendance(
      source: source ?? this.source,
      students: students ?? this.students,
      classId: classId ?? this.classId,
      section: section ?? this.section,
      standard: standard ?? this.standard,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      attendanceTime: attendanceTime ?? this.attendanceTime,
      month: month ?? this.month,
      year: year ?? this.year,
      period: period ?? this.period,
      attendanceMode: attendanceMode ?? this.attendanceMode,
    );
  }
}

@HiveType(typeId: 13)
class AttendanceStudent {
  AttendanceStudent({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.admissionNumber,
    required this.isPresent,
    this.uid,
    this.attendanceMode,
  });

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) =>
      AttendanceStudent(
        id: json['Id'],
        name: json['Name'],
        rollNo: json['RollNo'],
        admissionNumber: json['AdmissionNumber'],
        isPresent: json['IsPresent'],
        uid: json['UID'],
        attendanceMode: json['AttendanceMode'],
      );

  @HiveField(1)
  final String admissionNumber;

  @HiveField(2)
  final int id;

  @HiveField(3)
  final bool isPresent;

  @HiveField(4)
  final String name;

  @HiveField(5)
  final String rollNo;

  @HiveField(6)
  final String? uid;

  @HiveField(7)
  final String? attendanceMode;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'RollNo': rollNo,
    'AdmissionNumber': admissionNumber,
    'IsPresent': isPresent,
    'UID': uid,
    'AttendanceMode': attendanceMode,
  };

  AttendanceStudent copyWith({
    int? id,
    String? name,
    String? rollNo,
    String? admissionNumber,
    bool? isPresent,
    String? uid,
    String? attendanceMode,
  }) {
    return AttendanceStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      rollNo: rollNo ?? this.rollNo,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      isPresent: isPresent ?? this.isPresent,
      uid: uid ?? this.uid,
      attendanceMode: attendanceMode ?? this.attendanceMode,
    );
  }
}
