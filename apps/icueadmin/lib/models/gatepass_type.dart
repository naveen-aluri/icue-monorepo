// To parse this JSON data, do
//
//     final gatePassTypes = gatePassTypesFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

GatePassTypes gatePassTypesFromJson(String str) =>
    GatePassTypes.fromJson(json.decode(str));

String gatePassTypesToJson(GatePassTypes data) => json.encode(data.toJson());

class GatePassTypes {
  GatePassTypes({required this.err, required this.message, required this.data});

  factory GatePassTypes.fromJson(Map<String, dynamic> json) => GatePassTypes(
    err: json['err'],
    message: json['message'],
    data: List<GatePassType>.from(
      json['data'].map((x) => GatePassType.fromJson(x)),
    ),
  );

  final List<GatePassType> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class GatePassType {
  GatePassType({
    required this.id,
    required this.category,
    required this.displayName,
  });

  factory GatePassType.fromJson(Map<String, dynamic> json) => GatePassType(
    id: json['Id'],
    category: json['Category'],
    displayName: json['DisplayName'],
  );

  final String category;
  final String displayName;
  final int id;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Category': category,
    'DisplayName': displayName,
  };
}
