// To parse this JSON data, do
//
//     final fuelReport = fuelReportFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

List<FuelReport> fuelReportFromJson(String str) =>
    List<FuelReport>.from(json.decode(str).map((x) => FuelReport.fromJson(x)));

String fuelReportToJson(List<FuelReport> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FuelReport {
  FuelReport({
    required this.id,
    required this.zoneId,
    required this.branchId,
    required this.vehicleNumber,
    required this.fuelreading,
    required this.totalNoOfFuelReadings,
  });

  factory FuelReport.fromJson(Map<String, dynamic> json) => FuelReport(
    id: json['_id'],
    zoneId: json['ZoneId'],
    branchId: json['BranchId'],
    vehicleNumber: json['VehicleNumber'],
    fuelreading: List<Fuelreading>.from(
      json['FUELREADING'].map((x) => Fuelreading.fromJson(x)),
    ),
    totalNoOfFuelReadings: json['TotalNoOfFuelReadings'],
  );

  final int branchId;
  final List<Fuelreading> fuelreading;
  final String id;
  final int totalNoOfFuelReadings;
  final String vehicleNumber;
  final int zoneId;

  Map<String, dynamic> toJson() => {
    '_id': id,
    'ZoneId': zoneId,
    'BranchId': branchId,
    'VehicleNumber': vehicleNumber,
    'FUELREADING': List<dynamic>.from(fuelreading.map((x) => x.toJson())),
    'TotalNoOfFuelReadings': totalNoOfFuelReadings,
  };
}

class Fuelreading {
  Fuelreading({
    this.speedometer,
    this.fuelFilled,
    this.image,
    required this.date,
    required this.time,
    required this.dateTime,
    this.imgMode,
  });

  factory Fuelreading.fromJson(Map<String, dynamic> json) => Fuelreading(
    speedometer: json['Speedometer'],
    fuelFilled: json['FuelFilled'],
    image: json['Image'],
    date: json['Date'],
    time: json['Time'],
    imgMode: json['ImgMode'],
    dateTime: DateTime.parse(json['DateTime']),
  );

  final String date;
  final DateTime dateTime;
  final num? fuelFilled;
  final String? image;
  final String? imgMode;
  final num? speedometer;
  final String time;

  Map<String, dynamic> toJson() => {
    'Speedometer': speedometer,
    'FuelFilled': fuelFilled,
    'Image': image,
    'Date': date,
    'Time': time,
    'ImgMode': imgMode,
    'DateTime': dateTime.toIso8601String(),
  };
}
