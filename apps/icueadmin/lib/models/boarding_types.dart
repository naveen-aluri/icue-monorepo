// To parse this JSON data, do
//
//     final boardingTypes = boardingTypesFromJson(jsonString);

import 'dart:convert';

BoardingTypes boardingTypesFromJson(String str) =>
    BoardingTypes.fromJson(json.decode(str));

String boardingTypesToJson(BoardingTypes data) => json.encode(data.toJson());

class BoardingTypes {
  BoardingTypes({required this.err, required this.message, required this.data});

  factory BoardingTypes.fromJson(Map<String, dynamic> json) => BoardingTypes(
    err: json['err'],
    message: json['message'],
    data: List<BoardingType>.from(
      json['data'].map((x) => BoardingType.fromJson(x)),
    ),
  );

  final List<BoardingType> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class BoardingType {
  BoardingType({required this.id, required this.name});

  factory BoardingType.fromJson(Map<String, dynamic> json) =>
      BoardingType(id: json['Id'], name: json['Name']);

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'Id': id, 'Name': name};
}
