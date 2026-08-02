// To parse this JSON data, do
//
//     final complaintsDashboard = complaintsDashboardFromJson(jsonString);

import 'dart:convert';

import 'meta_data.dart';

ComplaintsDashboard complaintsDashboardFromJson(String str) =>
    ComplaintsDashboard.fromJson(json.decode(str));

String complaintsDashboardToJson(ComplaintsDashboard data) =>
    json.encode(data.toJson());

class ComplaintsDashboard {
  ComplaintsDashboard({
    required this.err,
    required this.message,
    required this.data,
    this.metadata,
  });

  factory ComplaintsDashboard.fromJson(Map<String, dynamic> json) =>
      ComplaintsDashboard(
        err: json['err'],
        message: json['message'],
        data: List<ComplaintDashboard>.from(
          json['data'].map((x) => ComplaintDashboard.fromJson(x)),
        ),
        metadata: json['metadata'] == null
            ? null
            : Metadata.fromJson(json['metadata']),
      );

  final List<ComplaintDashboard> data;
  final bool err;
  final String message;
  final Metadata? metadata;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'metadata': metadata?.toJson(),
  };
}

class ComplaintDashboard {
  ComplaintDashboard({
    required this.totalCount,
    this.status,
    this.category,
    this.statuses,
    this.categoryId,
    this.vehicle,
    this.vehicleId,
  });

  factory ComplaintDashboard.fromJson(Map<String, dynamic> json) =>
      ComplaintDashboard(
        totalCount: json['TotalCount'],
        status: json['Status'],
        category: json['Category'],
        statuses: json['Statuses'] == null
            ? []
            : List<Status>.from(
                json['Statuses']!.map((x) => Status.fromJson(x)),
              ),
        categoryId: json['CategoryId'],
        vehicle: json['Vehicle'],
        vehicleId: json['VehicleId'],
      );

  final String? category;
  final int? categoryId;
  final String? status;
  final List<Status>? statuses;
  final int totalCount;
  final String? vehicle;
  final int? vehicleId;

  Map<String, dynamic> toJson() => {
    'TotalCount': totalCount,
    'Status': status,
    'Category': category,
    'Statuses': statuses == null
        ? []
        : List<dynamic>.from(statuses!.map((x) => x.toJson())),
    'CategoryId': categoryId,
    'Vehicle': vehicle,
    'VehicleId': vehicleId,
  };
}

class Status {
  Status({required this.status, required this.count});

  factory Status.fromJson(Map<String, dynamic> json) =>
      Status(status: json['Status'], count: json['Count']);

  final int count;
  final String status;

  Map<String, dynamic> toJson() => {'Status': status, 'Count': count};
}
