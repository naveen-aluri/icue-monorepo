// To parse this JSON data, do
//
//     final personTypes = personTypesFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

part 'person_types.g.dart';

PersonTypes personTypesFromJson(String str) =>
    PersonTypes.fromJson(json.decode(str));

String personTypesToJson(PersonTypes data) => json.encode(data.toJson());

class PersonTypes {
  PersonTypes({required this.err, required this.message, required this.data});

  factory PersonTypes.fromJson(Map<String, dynamic> json) => PersonTypes(
    err: json['err'],
    message: json['message'],
    data: List<PersonType>.from(
      json['data'].map((x) => PersonType.fromJson(x)),
    ),
  );

  final List<PersonType> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 15)
class PersonType {
  PersonType({required this.id, required this.category});

  factory PersonType.fromJson(Map<String, dynamic> json) =>
      PersonType(id: json['Id'], category: json['Category']);

  @HiveField(0)
  final String category;

  @HiveField(1)
  final int id;

  Map<String, dynamic> toJson() => {'Id': id, 'Category': category};
}
