// To parse this JSON data, do
//
//     final expenseType = expenseTypeFromJson(jsonString);

// ignore_for_file: join_return_with_assignment, unnecessary_lambdas

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
part 'expense_type.g.dart';

List<ExpenseType> expenseTypeFromJson(String str) => List<ExpenseType>.from(
  json.decode(str).map((x) => ExpenseType.fromJson(x)),
);

String expenseTypeToJson(List<ExpenseType> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 16)
class ExpenseType {
  ExpenseType({
    required this.expenseType,
    required this.expenseTypeDesc,
    required this.code,
    required this.subItems,
    required this.expenseTypeDetails,
    required this.isMode,
    this.modes,
  });

  factory ExpenseType.fromJson(Map<String, dynamic> json) => ExpenseType(
    expenseType: json['ExpenseType'],
    expenseTypeDesc: json['ExpenseTypeDesc'],
    code: json['Code'],
    subItems: json['SubItems'],
    expenseTypeDetails: List<ExpenseTypeDetail>.from(
      json['ExpenseTypeDetails'].map((x) => ExpenseTypeDetail.fromJson(x)),
    ),
    isMode: json['IsMode'],
    modes: json['Modes'] == null
        ? []
        : List<ExpenseMode>.from(
            json['Modes']!.map((x) => ExpenseMode.fromJson(x)),
          ),
  );

  @HiveField(0)
  final String code;
  @HiveField(1)
  final int expenseType;
  @HiveField(2)
  final String expenseTypeDesc;
  @HiveField(3)
  final List<ExpenseTypeDetail> expenseTypeDetails;
  @HiveField(4)
  final bool isMode;
  @HiveField(5)
  final List<ExpenseMode>? modes;
  @HiveField(6)
  final bool subItems;

  Map<String, dynamic> toJson() => {
    'ExpenseType': expenseType,
    'ExpenseTypeDesc': expenseTypeDesc,
    'Code': code,
    'SubItems': subItems,
    'ExpenseTypeDetails': List<dynamic>.from(
      expenseTypeDetails.map((x) => x.toJson()),
    ),
    'IsMode': isMode,
    'Modes': modes == null
        ? []
        : List<dynamic>.from(modes!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 17)
class ExpenseTypeDetail {
  ExpenseTypeDetail({
    required this.id,
    required this.name,
    required this.code,
    this.details,
    required this.type,
    required this.isRequired,
    this.regexPattern,
  });

  factory ExpenseTypeDetail.fromJson(Map<String, dynamic> json) =>
      ExpenseTypeDetail(
        id: json['Id'],
        name: json['Name'],
        code: json['Code'],
        details: json['Details'] == null
            ? []
            : List<Detail>.from(
                json['Details']!.map((x) => Detail.fromJson(x)),
              ),
        type: json['Type'],
        isRequired: json['IsRequired'],
        regexPattern: json['RegexPattern'],
      );

  @HiveField(0)
  final String code;
  @HiveField(1)
  final List<Detail>? details;
  @HiveField(2)
  final int id;
  @HiveField(3)
  final bool isRequired;
  @HiveField(4)
  final String name;
  @HiveField(5)
  final String? regexPattern;
  @HiveField(6)
  final String type;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'Code': code,
    'Details': details == null
        ? []
        : List<dynamic>.from(details!.map((x) => x.toJson())),
    'Type': type,
    'IsRequired': isRequired,
    'RegexPattern': regexPattern,
  };
}

@HiveType(typeId: 19)
class Detail {
  Detail({required this.id, required this.name});

  factory Detail.fromJson(Map<String, dynamic> json) =>
      Detail(id: json['Id'], name: json['Name']);

  @HiveField(0)
  final dynamic id;
  @HiveField(1)
  final String? name;

  Map<String, dynamic> toJson() => {'Id': id, 'Name': name};
}

@HiveType(typeId: 18)
class ExpenseMode {
  ExpenseMode({required this.id, required this.name, required this.code});

  factory ExpenseMode.fromJson(Map<String, dynamic> json) =>
      ExpenseMode(id: json['Id'], name: json['Name'], code: json['Code']);

  @HiveField(0)
  final String code;
  @HiveField(1)
  final int id;
  @HiveField(2)
  final String name;

  Map<String, dynamic> toJson() => {'Id': id, 'Name': name, 'Code': code};
}
