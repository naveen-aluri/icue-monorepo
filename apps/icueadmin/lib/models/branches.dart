// To parse this JSON data, do
//
//     final branchs = branchsFromJson(jsonString);

import 'dart:convert';

import 'package:hive/hive.dart';
part 'branches.g.dart';

Branchs branchsFromJson(String str) => Branchs.fromJson(json.decode(str));

String branchsToJson(Branchs data) => json.encode(data.toJson());

class Branchs {
  Branchs({required this.err, required this.message, required this.data});

  factory Branchs.fromJson(Map<String, dynamic> json) => Branchs(
    err: json['err'],
    message: json['message'],
    data: List<Branch>.from(json['data'].map((x) => Branch.fromJson(x))),
  );

  final List<Branch> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 22)
class Branch {
  Branch({
    required this.id,
    required this.schoolName,
    required this.schoolShortName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json['Id'],
    schoolName: json['SchoolName'],
    schoolShortName: json['SchoolShortName'],
  );

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String schoolName;

  @HiveField(2)
  final String schoolShortName;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'SchoolName': schoolName,
    'SchoolShortName': schoolShortName,
  };
}
