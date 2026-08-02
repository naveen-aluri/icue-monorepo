// To parse this JSON data, do
//
//     final student = studentFromJson(jsonString);

// ignore_for_file: join_return_with_assignment, unnecessary_lambdas

import 'dart:convert';

import 'routes.dart';

List<Student> studentFromJson(String str) =>
    List<Student>.from(json.decode(str).map((x) => Student.fromJson(x)));

String studentToJson(List<Student> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Student {
  Student({required this.metadata, required this.data});

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    metadata: List<Metadatum>.from(
      json['metadata'].map((x) => Metadatum.fromJson(x)),
    ),
    data: List<StudentData>.from(
      json['data'].map((x) => StudentData.fromJson(x)),
    ),
  );

  final List<StudentData> data;
  final List<Metadatum> metadata;

  Map<String, dynamic> toJson() => {
    'metadata': List<dynamic>.from(metadata.map((x) => x.toJson())),
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

List<StudentData> studentDataFromJson(String str) => List<StudentData>.from(
  json.decode(str).map((x) => StudentData.fromJson(x)),
);

String studentDataToJson(List<StudentData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudentData {
  StudentData({
    required this.routestr,
    required this.id,
    required this.admissionNumber,
    required this.section,
    required this.name,
    required this.rollNo,
    required this.gender,
    required this.dateOfBirth,
    required this.standard,
    required this.classId,
    required this.academicYear,
    required this.parentName,
    required this.isTransportOpted,
    required this.isMessOpted,
    required this.identificationId,
    required this.escortId,
    this.isQrCodeAssigned,
    required this.pickPoint,
    this.routeIds,
    required this.dropPoint,
    required this.pickArea,
    required this.dropArea,
    required this.uid,
    this.assignedBy,
    this.assignedDate,
    required this.unAssignedCards,
    required this.mode,
    required this.routes,
    this.unAssignedEscortCards,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) => StudentData(
    routestr: List<String>.from(json['routestr'].map((x) => x)),
    id: json['Id'],
    admissionNumber: json['AdmissionNumber'],
    section: json['Section'],
    name: json['Name'],
    rollNo: json['RollNo'],
    gender: genderValues.map[json['Gender']]!,
    dateOfBirth: json['DateOfBirth'],
    standard: json['Standard'],
    classId: json['ClassId'],
    academicYear: json['AcademicYear'],
    parentName: json['ParentName'],
    isTransportOpted: json['IsTransportOpted'],
    isMessOpted: json['IsMessOpted'],
    identificationId: json['IdentificationId'],
    escortId: List<EscortId>.from(
      json['EscortId'].map((x) => EscortId.fromJson(x)),
    ),
    isQrCodeAssigned: json['IsQRCodeAssigned'],
    pickPoint: json['PickPoint'],
    dropPoint: json['DropPoint'],
    pickArea: json['PickArea'],
    dropArea: json['DropArea'],
    uid: json['UID'],
    assignedBy: json['AssignedBy'],
    assignedDate: json['AssignedDate'],
    unAssignedCards: json['UnAssignedCards'] == null
        ? null
        : UnAssignedCards.fromJson(json['UnAssignedCards']),
    mode: List<Mode>.from(json['mode'].map((x) => modeValues.map[x]!)),
    routes: List<String>.from(json['routes'].map((x) => x)),
    routeIds: json['routeIds'] == null
        ? null
        : List<String>.from(json['routeIds'].map((x) => x)),
    unAssignedEscortCards: json['UnAssignedEscortCards'] == null
        ? []
        : List<UnAssignedEscortCard>.from(
            json['UnAssignedEscortCards']!.map(
              (x) => UnAssignedEscortCard.fromJson(x),
            ),
          ),
  );

  final String academicYear;
  final String admissionNumber;
  final String? assignedBy;
  final String? assignedDate;
  final int classId;
  final String dateOfBirth;
  final String? dropArea;
  final String? dropPoint;
  final List<EscortId> escortId;
  final Gender gender;
  final int id;
  final String? identificationId;
  final bool isMessOpted;
  final bool? isQrCodeAssigned;
  final bool? isTransportOpted;
  final List<Mode> mode;
  final String name;
  final String parentName;
  final String? pickArea;
  final String? pickPoint;
  final String rollNo;
  final List<String>? routeIds;
  final List<String> routes;
  final List<String> routestr;
  final String section;
  final String standard;
  final String? uid;
  final UnAssignedCards? unAssignedCards;
  final List<UnAssignedEscortCard>? unAssignedEscortCards;

  Map<String, dynamic> toJson() => {
    'routestr': List<dynamic>.from(routes.map((x) => x)),
    'Id': id,
    'AdmissionNumber': admissionNumber,
    'Section': section,
    'Name': name,
    'RollNo': rollNo,
    'Gender': genderValues.reverse[gender],
    'DateOfBirth': dateOfBirth,
    'Standard': standard,
    'ClassId': classId,
    'AcademicYear': academicYear,
    'ParentName': parentName,
    'IsTransportOpted': isTransportOpted,
    'IsMessOpted': isMessOpted,
    'IdentificationId': identificationId,
    'EscortId': List<dynamic>.from(escortId.map((x) => x.toJson())),
    'IsQRCodeAssigned': isQrCodeAssigned,
    'PickPoint': pickPoint,
    'DropPoint': dropPoint,
    'PickArea': pickArea,
    'DropArea': dropArea,
    'UID': uid,
    'AssignedBy': assignedBy,
    'AssignedDate': assignedDate,
    'UnAssignedCards': unAssignedCards?.toJson(),
    'mode': List<dynamic>.from(mode.map((x) => modeValues.reverse[x])),
    'routes': List<dynamic>.from(routes.map((x) => x)),
    'routeIds': routeIds == null
        ? null
        : List<dynamic>.from(routeIds!.map((x) => x)),
    'UnAssignedEscortCards': unAssignedEscortCards == null
        ? []
        : List<dynamic>.from(unAssignedEscortCards!.map((x) => x.toJson())),
  };
}

class EscortId {
  EscortId({
    required this.name,
    required this.id,
    this.createdBy,
    // required this.createdDate,
  });

  factory EscortId.fromJson(Map<String, dynamic> json) => EscortId(
    name: json['Name'],
    id: json['Id'],
    createdBy: json['CreatedBy'],
    // createdDate: DateTime.parse(json['CreatedDate']),
  );

  final String? createdBy;
  // final DateTime createdDate;
  final String id;
  final String name;

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Id': id,
    'CreatedBy': createdBy,
    // 'CreatedDate': createdDate.toIso8601String(),
  };
}

enum Gender { F, M }

final genderValues = EnumValues({'f': Gender.F, 'm': Gender.M});

class UnAssignedCards {
  UnAssignedCards({
    this.identificationId,
    required this.updatedBy,
    required this.date,
  });

  factory UnAssignedCards.fromJson(Map<String, dynamic> json) =>
      UnAssignedCards(
        identificationId: json['IdentificationId'],
        updatedBy: json['UpdatedBy'],
        date: DateTime.parse(json['Date']),
      );

  final DateTime date;
  final String? identificationId;
  final String updatedBy;

  Map<String, dynamic> toJson() => {
    'IdentificationId': identificationId,
    'UpdatedBy': updatedBy,
    'Date': date.toIso8601String(),
  };
}

class UnAssignedEscortCard {
  UnAssignedEscortCard({this.id, this.name, this.updatedBy, this.date});

  factory UnAssignedEscortCard.fromJson(Map<String, dynamic> json) =>
      UnAssignedEscortCard(
        id: json['Id'],
        name: json['Name'],
        updatedBy: json['UpdatedBy'],
        date: json['Date'] == null ? null : DateTime.parse(json['Date']),
      );

  final DateTime? date;
  final String? id;
  final dynamic name;
  final String? updatedBy;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'UpdatedBy': updatedBy,
    'Date': date?.toIso8601String(),
  };
}

class Metadatum {
  Metadatum({required this.total, required this.page, required this.pagesize});

  factory Metadatum.fromJson(Map<String, dynamic> json) => Metadatum(
    total: json['total'],
    page: json['page'],
    pagesize: json['pagesize'],
  );

  final int page;
  final int pagesize;
  final int total;

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'pagesize': pagesize,
  };
}

class EnumValues<T> {
  EnumValues(this.map);

  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
