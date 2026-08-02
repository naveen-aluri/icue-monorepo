// To parse this JSON data, do
//
//     final alcoholTestReport = alcoholTestReportFromJson(jsonString);

import 'dart:convert';

import 'meta_data.dart';

AlcoholTestReport alcoholTestReportFromJson(String str) =>
    AlcoholTestReport.fromJson(json.decode(str));

String alcoholTestReportToJson(AlcoholTestReport data) =>
    json.encode(data.toJson());

class AlcoholTestReport {
  AlcoholTestReport({
    required this.metadata,
    required this.data,
    required this.err,
    required this.message,
  });

  factory AlcoholTestReport.fromJson(Map<String, dynamic> json) =>
      AlcoholTestReport(
        metadata: Metadata.fromJson(json['metadata']),
        data: List<AlcoholTest>.from(
          json['data'].map((x) => AlcoholTest.fromJson(x)),
        ),
        err: json['err'],
        message: json['message'],
      );

  final List<AlcoholTest> data;
  final bool err;
  final String message;
  final Metadata metadata;

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'err': err,
    'message': message,
  };
}

class AlcoholTest {
  AlcoholTest({
    this.id,
    this.submittedDate,
    this.submittedTime,
    this.personType,
    this.personInfo,
    this.alcoholTest,
    this.alcoholTestReading,
    this.imageUrl,
    this.createdBy,
  });

  factory AlcoholTest.fromJson(Map<String, dynamic> json) => AlcoholTest(
    id: json['Id'],
    submittedDate: json['SubmittedDate'],
    submittedTime: json['SubmittedTime'],
    personType: json['PersonType'],
    personInfo: json['PersonInfo'] == null
        ? null
        : PersonInfo.fromJson(json['PersonInfo']),
    alcoholTest: json['AlcoholTest'],
    alcoholTestReading: json['AlcoholTestReading'],
    imageUrl: json['ImageUrl'],
    createdBy: json['CreatedBy'],
  );

  final String? alcoholTest;
  final num? alcoholTestReading;
  final String? createdBy;
  final int? id;
  final String? imageUrl;
  final PersonInfo? personInfo;
  final String? personType;
  final String? submittedDate;
  final String? submittedTime;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'SubmittedDate': submittedDate,
    'SubmittedTime': submittedTime,
    'PersonType': personType,
    'PersonInfo': personInfo?.toJson(),
    'AlcoholTest': alcoholTest,
    'AlcoholTestReading': alcoholTestReading,
    'ImageUrl': imageUrl,
    'CreatedBy': createdBy,
  };
}

class PersonInfo {
  PersonInfo({required this.name, required this.mobile});

  factory PersonInfo.fromJson(Map<String, dynamic> json) =>
      PersonInfo(name: json['Name'], mobile: json['Mobile']);

  final dynamic mobile;
  final String name;

  Map<String, dynamic> toJson() => {'Name': name, 'Mobile': mobile};
}
