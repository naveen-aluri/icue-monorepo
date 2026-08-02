// To parse this JSON data, do
//
//     final arrivalTimeReport = arrivalTimeReportFromJson(jsonString);

import 'dart:convert';

import 'meta_data.dart';

ArrivalTimeReport arrivalTimeReportFromJson(String str) =>
    ArrivalTimeReport.fromJson(json.decode(str));

String arrivalTimeReportToJson(ArrivalTimeReport data) =>
    json.encode(data.toJson());

class ArrivalTimeReport {
  ArrivalTimeReport({
    required this.err,
    required this.message,
    required this.data,
  });

  factory ArrivalTimeReport.fromJson(Map<String, dynamic> json) =>
      ArrivalTimeReport(
        err: json['err'],
        message: json['message'],
        data: Data.fromJson(json['data']),
      );

  final Data data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': data.toJson(),
  };
}

class Data {
  Data({required this.metadata, required this.data});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    metadata: json['metadata'] is Map
        ? Metadata.fromJson(json['metadata'])
        : const Metadata(total: 0, page: 1, pagesize: 10),
    data: List<TimeReport>.from(
      json['data'].map((x) => TimeReport.fromJson(x)),
    ),
  );

  final List<TimeReport> data;
  final Metadata metadata;

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class TimeReport {
  TimeReport({
    required this.vehicleNumber,
    required this.routeNo,
    required this.mode,
    required this.startDate,
    required this.startTime,
    this.endDate,
    this.endTime,
    this.arrivalTime,
  });

  factory TimeReport.fromJson(Map<String, dynamic> json) => TimeReport(
    vehicleNumber: json['VehicleNumber'],
    routeNo: json['RouteNo'],
    mode: json['Mode'],
    startDate: json['StartDate'],
    startTime: json['StartTime'],
    endDate: json['EndDate'],
    endTime: json['EndTime'],
    arrivalTime: json['ArrivalTime'],
  );

  final String? arrivalTime;
  final String? endDate;
  final String? endTime;
  final String mode;
  final String routeNo;
  final String startDate;
  final String startTime;
  final String vehicleNumber;

  Map<String, dynamic> toJson() => {
    'VehicleNumber': vehicleNumber,
    'RouteNo': routeNo,
    'Mode': mode,
    'StartDate': startDate,
    'StartTime': startTime,
    'EndDate': endDate,
    'EndTime': endTime,
    'ArrivalTime': arrivalTime,
  };
}
