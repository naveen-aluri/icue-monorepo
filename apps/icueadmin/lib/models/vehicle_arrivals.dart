// To parse this JSON data, do
//
//     final vehicleArrivals = vehicleArrivalsFromJson(jsonString);

import 'dart:convert';

VehicleArrivals vehicleArrivalsFromJson(String str) =>
    VehicleArrivals.fromJson(json.decode(str));

String vehicleArrivalsToJson(VehicleArrivals data) =>
    json.encode(data.toJson());

class VehicleArrivals {
  VehicleArrivals({
    required this.err,
    required this.message,
    required this.data,
  });

  factory VehicleArrivals.fromJson(Map<String, dynamic> json) =>
      VehicleArrivals(
        err: json['err'],
        message: json['message'],
        data: List<VehicleArrival>.from(
          json['data'].map((x) => VehicleArrival.fromJson(x)),
        ),
      );

  final List<VehicleArrival> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

List<VehicleArrival> vehicleArrivalFromJson(String str) =>
    List<VehicleArrival>.from(
      json.decode(str).map((x) => VehicleArrival.fromJson(x)),
    );

String vehicleArrivalToJson(List<VehicleArrival> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VehicleArrival {
  VehicleArrival({
    required this.id,
    required this.routeNo,
    required this.vehicleNumber,
    required this.status,
    this.boardingType,
  });

  factory VehicleArrival.fromJson(Map<String, dynamic> json) => VehicleArrival(
    id: json['RouteId'],
    routeNo: json['RouteNo'],
    vehicleNumber: json['VehicleNumber'],
    status: json['Status'],
    boardingType: json['BoardingType'],
  );

  final String? boardingType;
  final int id;
  final String routeNo;
  final String status;
  final String vehicleNumber;

  Map<String, dynamic> toJson() => {
    'RouteId': id,
    'RouteNo': routeNo,
    'VehicleNumber': vehicleNumber,
    'Status': status,
    'BoardingType': boardingType,
  };
}
