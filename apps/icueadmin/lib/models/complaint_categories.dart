// To parse this JSON data, do
//
//     final complaintCategories = complaintCategoriesFromJson(jsonString);

import 'dart:convert';

ComplaintCategories complaintCategoriesFromJson(String str) =>
    ComplaintCategories.fromJson(json.decode(str));

String complaintCategoriesToJson(ComplaintCategories data) =>
    json.encode(data.toJson());

class ComplaintCategories {
  ComplaintCategories({
    required this.err,
    required this.message,
    required this.data,
    required this.actions,
  });

  factory ComplaintCategories.fromJson(Map<String, dynamic> json) =>
      ComplaintCategories(
        err: json['err'],
        message: json['message'],
        data: List<ComplaintCategory>.from(
          json['data'].map((x) => ComplaintCategory.fromJson(x)),
        ),
        actions: List<ComplaintAction>.from(
          json['actions'].map((x) => ComplaintAction.fromJson(x)),
        ),
      );

  final List<ComplaintAction> actions;
  final List<ComplaintCategory> data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'actions': List<dynamic>.from(actions.map((x) => x.toJson())),
  };
}

class ComplaintAction {
  ComplaintAction({required this.action, required this.status});

  factory ComplaintAction.fromJson(Map<String, dynamic> json) =>
      ComplaintAction(action: json['Action'], status: json['Status']);

  final String action;
  final String status;

  Map<String, dynamic> toJson() => {'Action': action, 'Status': status};
}

class ComplaintCategory {
  ComplaintCategory({required this.id, required this.name});

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) =>
      ComplaintCategory(id: json['Id'], name: json['Name']);

  final int id;
  final String name;

  Map<String, dynamic> toJson() => {'Id': id, 'Name': name};
}
