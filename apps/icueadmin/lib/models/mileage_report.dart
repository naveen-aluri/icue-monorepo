// To parse this JSON data, do
//
//     final mileageReport = mileageReportFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

List<MileageReport> mileageReportFromJson(String str) =>
    List<MileageReport>.from(
      json.decode(str).map((x) => MileageReport.fromJson(x)),
    );

String mileageReportToJson(List<MileageReport> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MileageReport {
  MileageReport({
    required this.vehicleNumber,
    required this.routeNo,
    required this.actualTotalKmsDriven,
    required this.totalNoOfKmReadingsTaken,
    required this.speedometerdiff,
  });

  factory MileageReport.fromJson(Map<String, dynamic> json) => MileageReport(
    vehicleNumber: json['VehicleNumber'],
    routeNo: json['RouteNo'],
    actualTotalKmsDriven: json['ActualTotalKmsDriven'],
    totalNoOfKmReadingsTaken: json['TotalNoOfKMReadingsTaken'],
    speedometerdiff: json['SPEEDOMETERDIFF'],
  );

  final dynamic actualTotalKmsDriven;
  final String routeNo;
  final String speedometerdiff;
  final num totalNoOfKmReadingsTaken;
  final String vehicleNumber;

  Map<String, dynamic> toJson() => {
    'VehicleNumber': vehicleNumber,
    'RouteNo': routeNo,
    'ActualTotalKmsDriven': actualTotalKmsDriven,
    'TotalNoOfKMReadingsTaken': totalNoOfKmReadingsTaken,
    'SPEEDOMETERDIFF': speedometerdiff,
  };
}
