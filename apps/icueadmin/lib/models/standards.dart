// To parse this JSON data, do
//
//     final standards = standardsFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'package:hive/hive.dart';

part 'standards.g.dart';

List<Standards> standardsFromJson(String str) =>
    List<Standards>.from(json.decode(str).map((x) => Standards.fromJson(x)));

String standardsToJson(List<Standards> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 5)
class Standards {
  Standards({
    required this.id,
    required this.name,
    required this.sections,
    this.standardType,
    this.subjects,
  });

  factory Standards.fromJson(Map<String, dynamic> json) => Standards(
    id: json['Id'],
    name: json['Name'],
    sections: List<Section>.from(
      json['Sections'].map((x) => Section.fromJson(x)),
    ),
    standardType: json['StandardType'],
    subjects: json['Subjects'] == null
        ? []
        : List<dynamic>.from(json['Subjects']!.map((x) => x)),
  );

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<Section> sections;

  @HiveField(3)
  final String? standardType;

  @HiveField(4)
  final List<dynamic>? subjects;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'Sections': List<dynamic>.from(sections.map((x) => x.toJson())),
    'StandardType': standardType,
    'Subjects': subjects == null
        ? []
        : List<dynamic>.from(subjects!.map((x) => x)),
  };
}

@HiveType(typeId: 6)
class Section {
  Section({required this.name, this.id, this.uid});

  factory Section.fromJson(Map<String, dynamic> json) =>
      Section(name: json['Name'], id: json['id'], uid: json['UID']);

  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? uid;

  Map<String, dynamic> toJson() => {'Name': name, 'id': id, 'UID': uid};
}
