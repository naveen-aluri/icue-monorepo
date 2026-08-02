// To parse this JSON data, do
//
//     final expenseCategory = expenseCategoryFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'expense_type.dart';

ExpenseCategory expenseCategoryFromJson(String str) =>
    ExpenseCategory.fromJson(json.decode(str));

String expenseCategoryToJson(ExpenseCategory data) =>
    json.encode(data.toJson());

class ExpenseCategory {
  ExpenseCategory({
    required this.err,
    required this.message,
    required this.record,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      ExpenseCategory(
        err: json['err'],
        message: json['message'],
        record: List<Detail>.from(
          json['Record'].map((x) => Detail.fromJson(x)),
        ),
      );

  final bool err;
  final String message;
  final List<Detail> record;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'Record': List<dynamic>.from(record.map((x) => x.toJson())),
  };
}
