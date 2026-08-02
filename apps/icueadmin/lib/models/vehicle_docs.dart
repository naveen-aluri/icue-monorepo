// To parse this JSON data, do
//
//     final vehicleDocs = vehicleDocsFromJson(jsonString);

import 'dart:convert';

VehicleDocs vehicleDocsFromJson(String str) =>
    VehicleDocs.fromJson(json.decode(str));

String vehicleDocsToJson(VehicleDocs data) => json.encode(data.toJson());

class VehicleDocs {
  VehicleDocs({required this.err, required this.message, required this.docs});

  factory VehicleDocs.fromJson(Map<String, dynamic> json) => VehicleDocs(
    err: json['err'],
    message: json['message'],
    docs: Docs.fromJson(json['docs']),
  );

  final Docs docs;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'docs': docs.toJson(),
  };
}

class Docs {
  Docs({
    required this.recordId,
    required this.type,
    this.rcNumber,
    this.rcStartDate,
    this.rcExpiryDate,
    required this.docUrl,
    required this.contentType,
    this.insuranceNumber,
    this.insuredDate,
    this.insuranceExpiryDate,
    this.fitnessNumber,
    this.fitnessStartDate,
    this.fitnessExpiryDate,
    this.roadTaxNumber,
    this.roadTaxStartDate,
    this.roadTaxExpiryDate,
    this.pollutionNumber,
    this.pollutionStartDate,
    this.pollutionExpiryDate,
    this.permitNumber,
    this.permitStartDate,
    this.permitExpiryDate,
  });

  factory Docs.fromJson(Map<String, dynamic> json) => Docs(
    recordId: json['RecordId'],
    type: json['Type'],
    rcNumber: json['RCNumber'],
    rcStartDate: json['RCStartDate'],
    rcExpiryDate: json['RCExpiryDate'],
    docUrl: json['DocUrl'],
    contentType: json['ContentType'],
    insuranceNumber: json['InsuranceNumber'],
    insuredDate: json['InsuredDate'],
    insuranceExpiryDate: json['InsuranceExpiryDate'],
    fitnessNumber: json['FitnessNumber'],
    fitnessStartDate: json['FitnessStartDate'],
    fitnessExpiryDate: json['FitnessExpiryDate'],
    roadTaxNumber: json['RoadTaxNumber'],
    roadTaxStartDate: json['RoadTaxStartDate'],
    roadTaxExpiryDate: json['RoadTaxExpiryDate'],
    pollutionNumber: json['PollutionNumber'],
    pollutionStartDate: json['PollutionStartDate'],
    pollutionExpiryDate: json['PollutionExpiryDate'],
    permitNumber: json['PermitNumber'],
    permitStartDate: json['PermitStartDate'],
    permitExpiryDate: json['PermitExpiryDate'],
  );

  final String contentType;
  final String docUrl;
  final String? fitnessExpiryDate;
  final String? fitnessNumber;
  final String? fitnessStartDate;
  final String? insuranceExpiryDate;
  final String? insuranceNumber;
  final String? insuredDate;
  final String? permitExpiryDate;
  final String? permitNumber;
  final String? permitStartDate;
  final String? pollutionExpiryDate;
  final String? pollutionNumber;
  final String? pollutionStartDate;
  final String? rcExpiryDate;
  final String? rcNumber;
  final String? rcStartDate;
  final int recordId;
  final String? roadTaxExpiryDate;
  final String? roadTaxNumber;
  final String? roadTaxStartDate;
  final String type;

  Map<String, dynamic> toJson() => {
    'RecordId': recordId,
    'Type': type,
    'RCNumber': rcNumber,
    'RCStartDate': rcStartDate,
    'RCExpiryDate': rcExpiryDate,
    'DocUrl': docUrl,
    'ContentType': contentType,
    'InsuranceNumber': insuranceNumber,
    'InsuredDate': insuredDate,
    'InsuranceExpiryDate': insuranceExpiryDate,
    'FitnessNumber': fitnessNumber,
    'FitnessStartDate': fitnessStartDate,
    'FitnessExpiryDate': fitnessExpiryDate,
    'RoadTaxNumber': roadTaxNumber,
    'RoadTaxStartDate': roadTaxStartDate,
    'RoadTaxExpiryDate': roadTaxExpiryDate,
    'PollutionNumber': pollutionNumber,
    'PollutionStartDate': pollutionStartDate,
    'PollutionExpiryDate': pollutionExpiryDate,
    'PermitNumber': permitNumber,
    'PermitStartDate': permitStartDate,
    'PermitExpiryDate': permitExpiryDate,
  };
}
