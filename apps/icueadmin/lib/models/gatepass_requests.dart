// To parse this JSON data, do
//
//     final gatePassRequests = gatePassRequestsFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

GatePassRequests gatePassRequestsFromJson(String str) =>
    GatePassRequests.fromJson(json.decode(str));

String gatePassRequestsToJson(GatePassRequests data) =>
    json.encode(data.toJson());

class GatePassRequests {
  GatePassRequests({
    required this.err,
    required this.message,
    required this.data,
  });

  factory GatePassRequests.fromJson(Map<String, dynamic> json) =>
      GatePassRequests(
        err: json['err'],
        message: json['message'],
        data: List<GatePassRequest>.from(
          json['data'].map((x) => GatePassRequest.fromJson(x)),
        ),
      );

  final List<GatePassRequest> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class GatePassRequest {
  GatePassRequest({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.zoneId,
    required this.personType,
    required this.gatePassType,
    required this.datumClass,
    required this.section,
    required this.admissionNumber,
    required this.name,
    required this.personId,
    required this.isHostelite,
    required this.hostelType,
    required this.requestDate,
    required this.requestTime,
    required this.requestDt,
  });

  factory GatePassRequest.fromJson(Map<String, dynamic> json) =>
      GatePassRequest(
        id: json['Id'],
        organizationId: json['OrganizationId'],
        branchId: json['BranchId'],
        zoneId: json['ZoneId'],
        personType: json['PersonType'],
        gatePassType: json['GatePassType'],
        datumClass: json['Class'],
        section: json['Section'],
        admissionNumber: json['AdmissionNumber'],
        name: json['Name'],
        personId: json['PersonId'],
        isHostelite: json['IsHostelite'],
        hostelType: json['HostelType'],
        requestDate: json['RequestDate'],
        requestTime: json['RequestTime'],
        requestDt: json['RequestDt'],
      );

  final String admissionNumber;
  final int branchId;
  final String datumClass;
  final String gatePassType;
  final String hostelType;
  final int id;
  final bool isHostelite;
  final String name;
  final int organizationId;
  final int personId;
  final String personType;
  final String requestDate;
  final String requestDt;
  final String requestTime;
  final String section;
  final int zoneId;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'OrganizationId': organizationId,
    'BranchId': branchId,
    'ZoneId': zoneId,
    'PersonType': personType,
    'GatePassType': gatePassType,
    'Class': datumClass,
    'Section': section,
    'AdmissionNumber': admissionNumber,
    'Name': name,
    'PersonId': personId,
    'IsHostelite': isHostelite,
    'HostelType': hostelType,
    'RequestDate': requestDate,
    'RequestTime': requestTime,
    'RequestDt': requestDt,
  };
}
