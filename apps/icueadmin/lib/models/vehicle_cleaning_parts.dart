// To parse this JSON data, do
//
//     final vehicleCleaningParts = vehicleCleaningPartsFromJson(jsonString);

import 'dart:convert';

VehicleCleaningParts vehicleCleaningPartsFromJson(String str) =>
    VehicleCleaningParts.fromJson(json.decode(str));

String vehicleCleaningPartsToJson(VehicleCleaningParts data) =>
    json.encode(data.toJson());

class VehicleCleaningParts {
  VehicleCleaningParts({
    required this.err,
    required this.message,
    required this.data,
  });

  factory VehicleCleaningParts.fromJson(Map<String, dynamic> json) =>
      VehicleCleaningParts(
        err: json['err'],
        message: json['message'],
        data: List<CleaningParts>.from(
          json['data'].map((x) => CleaningParts.fromJson(x)),
        ),
      );

  final List<CleaningParts> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CleaningParts {
  CleaningParts({required this.id, required this.name});

  factory CleaningParts.fromJson(Map<String, dynamic> json) =>
      CleaningParts(id: json['Id'], name: json['Name']);

  final int id;
  final String name;

  Map<String, dynamic> toJson() => {'Id': id, 'Name': name};
}
