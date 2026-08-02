// To parse this JSON data, do
//
//     final overSpeedReport = overSpeedReportFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

List<OverSpeedReport> overSpeedReportFromJson(String str) =>
    List<OverSpeedReport>.from(
      json.decode(str).map((x) => OverSpeedReport.fromJson(x)),
    );

String overSpeedReportToJson(List<OverSpeedReport> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OverSpeedReport {
  OverSpeedReport({
    required this.vehicleNumber,
    required this.driverName,
    required this.driverMobile,
    required this.mode,
    required this.routeNo,
    required this.startPoint,
    required this.endPoint,
    required this.startTime,
    required this.endTime,
    required this.startDate,
    required this.averageSpeed,
    required this.overSpeedData,
  });

  factory OverSpeedReport.fromJson(Map<String, dynamic> json) =>
      OverSpeedReport(
        vehicleNumber: json['VehicleNumber'],
        driverName: json['DriverName'],
        driverMobile: json['DriverMobile'],
        mode: json['Mode'],
        routeNo: json['RouteNo'],
        startPoint: json['StartPoint'],
        endPoint: json['EndPoint'],
        startTime: json['StartTime'],
        endTime: json['EndTime'],
        startDate: json['StartDate'],
        averageSpeed: json['AverageSpeed'],
        overSpeedData: List<OverSpeedDatum>.from(
          json['OverSpeedData'].map((x) => OverSpeedDatum.fromJson(x)),
        ),
      );

  final num? averageSpeed;
  final int driverMobile;
  final String driverName;
  final String endPoint;
  final String endTime;
  final String mode;
  final List<OverSpeedDatum> overSpeedData;
  final String routeNo;
  final String startDate;
  final String startPoint;
  final String startTime;
  final String vehicleNumber;

  Map<String, dynamic> toJson() => {
    'VehicleNumber': vehicleNumber,
    'DriverName': driverName,
    'DriverMobile': driverMobile,
    'Mode': mode,
    'RouteNo': routeNo,
    'StartPoint': startPoint,
    'EndPoint': endPoint,
    'StartTime': startTime,
    'EndTime': endTime,
    'StartDate': startDate,
    'AverageSpeed': averageSpeed,
    'OverSpeedData': List<dynamic>.from(overSpeedData.map((x) => x.toJson())),
  };
}

class OverSpeedDatum {
  OverSpeedDatum({
    required this.time,
    required this.coordinates,
    required this.speed,
    required this.gpsTime,
  });

  factory OverSpeedDatum.fromJson(Map<String, dynamic> json) => OverSpeedDatum(
    time: json['time'],
    coordinates: List<double>.from(
      json['coordinates'].map((x) => x?.toDouble()),
    ),
    speed: json['speed'],
    gpsTime: json['gpsTime'],
  );

  final List<double> coordinates;
  final int gpsTime;
  final int speed;
  final String time;

  Map<String, dynamic> toJson() => {
    'time': time,
    'coordinates': List<dynamic>.from(coordinates.map((x) => x)),
    'speed': speed,
    'gpsTime': gpsTime,
  };
}

List<OverSpeed> overSpeedFromJson(String str) =>
    List<OverSpeed>.from(json.decode(str).map((x) => OverSpeed.fromJson(x)));

String overSpeedToJson(List<OverSpeed> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OverSpeed {
  OverSpeed({
    required this.vehicleNumber,
    required this.mode,
    required this.routeNo,
    required this.averageSpeed,
    required this.speed,
    required this.gpsTime,
  });

  factory OverSpeed.fromJson(Map<String, dynamic> json) => OverSpeed(
    vehicleNumber: json['VehicleNumber'],
    mode: json['Mode'],
    routeNo: json['RouteNo'],
    averageSpeed: json['AverageSpeed'],
    speed: json['speed'],
    gpsTime: DateTime.parse(json['gpsTime']),
  );

  final num averageSpeed;
  final DateTime gpsTime;
  final String mode;
  final String routeNo;
  final int speed;
  final String vehicleNumber;

  Map<String, dynamic> toJson() => {
    'VehicleNumber': vehicleNumber,
    'Mode': mode,
    'RouteNo': routeNo,
    'AverageSpeed': averageSpeed,
    'speed': speed,
    'gpsTime': gpsTime.toIso8601String(),
  };
}
