// To parse this JSON data, do
//
//     final complaintData = complaintDataFromJson(jsonString);

import 'dart:convert';

import 'meta_data.dart';

ComplaintData complaintDataFromJson(String str) =>
    ComplaintData.fromJson(json.decode(str));

String complaintDataToJson(ComplaintData data) => json.encode(data.toJson());

class ComplaintData {
  ComplaintData({
    required this.metadata,
    required this.data,
    required this.err,
    required this.message,
  });

  factory ComplaintData.fromJson(Map<String, dynamic> json) => ComplaintData(
    metadata: Metadata.fromJson(json['metadata']),
    data: List<Complaint>.from(json['data'].map((x) => Complaint.fromJson(x))),
    err: json['err'],
    message: json['message'],
  );

  final List<Complaint> data;
  final bool err;
  final String message;
  final Metadata metadata;

  Map<String, dynamic> toJson() => {
    'metadata': metadata.toJson(),
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'err': err,
    'message': message,
  };
}

class Complaint {
  Complaint({
    required this.id,
    required this.complaintNo,
    required this.vehicleNo,
    required this.categoryName,
    required this.details,
    required this.currStatus,
    required this.currAction,
    required this.stsUpdatedDt,
    required this.stsUpdatedTime,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: json['Id'],
    complaintNo: json['ComplaintNo'],
    vehicleNo: json['VehicleNo'],
    categoryName: json['CategoryName'],
    details: List<Detail>.from(json['Details'].map((x) => Detail.fromJson(x))),
    currStatus: json['CurrStatus'],
    currAction: json['CurrAction'],
    stsUpdatedDt: json['StsUpdatedDt'],
    stsUpdatedTime: json['StsUpdatedTime'],
  );

  final String categoryName;
  final int complaintNo;
  final String currAction;
  final String currStatus;
  final List<Detail> details;
  final int id;
  final String stsUpdatedDt;
  final String stsUpdatedTime;
  final String vehicleNo;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ComplaintNo': complaintNo,
    'VehicleNo': vehicleNo,
    'CategoryName': categoryName,
    'Details': List<dynamic>.from(details.map((x) => x.toJson())),
    'CurrStatus': currStatus,
    'CurrAction': currAction,
    'StsUpdatedDt': stsUpdatedDt,
    'StsUpdatedTime': stsUpdatedTime,
  };
}

class Detail {
  Detail({
    required this.status,
    required this.action,
    required this.date,
    required this.time,
    required this.description,
    required this.createdBy,
    required this.imageUrls,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
    status: json['Status'],
    action: json['Action'],
    date: json['Date'],
    time: json['Time'],
    description: json['Description'],
    createdBy: json['CreatedBy'],
    imageUrls: List<dynamic>.from(json['ImageUrls'].map((x) => x)),
  );

  final String action;
  final String createdBy;
  final String date;
  final String description;
  final List<dynamic> imageUrls;
  final String status;
  final String time;

  Map<String, dynamic> toJson() => {
    'Status': status,
    'Action': action,
    'Date': date,
    'Time': time,
    'Description': description,
    'CreatedBy': createdBy,
    'ImageUrls': List<dynamic>.from(imageUrls.map((x) => x)),
  };
}
