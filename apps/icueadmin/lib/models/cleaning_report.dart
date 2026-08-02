import 'dart:convert';

import 'meta_data.dart';

CleaningReport cleaningReportFromJson(String str) =>
    CleaningReport.fromJson(json.decode(str));

String cleaningReportToJson(CleaningReport data) => json.encode(data.toJson());

class CleaningReport {
  CleaningReport({this.metadata, this.data, this.err, this.message});

  factory CleaningReport.fromJson(Map<String, dynamic> json) => CleaningReport(
    metadata: json['metadata'] == null
        ? null
        : Metadata.fromJson(json['metadata']),
    data: json['data'] == null
        ? []
        : List<CleaningReportData>.from(
            json['data']!.map((x) => CleaningReportData.fromJson(x)),
          ),
    err: json['err'],
    message: json['message'],
  );

  final List<CleaningReportData>? data;
  final bool? err;
  final String? message;
  final Metadata? metadata;

  Map<String, dynamic> toJson() => {
    'metadata': metadata?.toJson(),
    'data': data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    'err': err,
    'message': message,
  };
}

class CleaningReportData {
  CleaningReportData({
    this.vehicleNo,
    this.cleanedData,
    this.createdBy,
    this.createdDate,
    this.source,
    this.createdTime,
    this.photos,
  });

  factory CleaningReportData.fromJson(Map<String, dynamic> json) =>
      CleaningReportData(
        vehicleNo: json['VehicleNo'],
        cleanedData: json['CleanedData'] == null
            ? []
            : List<CleanedDatum>.from(
                json['CleanedData']!.map((x) => CleanedDatum.fromJson(x)),
              ),
        createdBy: json['CreatedBy'],
        createdDate: json['CreatedDate'],
        source: json['Source'],
        createdTime: json['CreatedTime'],
        photos: json['Photos'] == null
            ? []
            : List<String>.from(json['Photos']!.map((x) => x)),
      );

  final List<CleanedDatum>? cleanedData;
  final String? createdBy;
  final String? createdDate;
  final String? createdTime;
  final List<String>? photos;
  final String? source;
  final String? vehicleNo;

  Map<String, dynamic> toJson() => {
    'VehicleNo': vehicleNo,
    'CleanedData': cleanedData == null
        ? []
        : List<dynamic>.from(cleanedData!.map((x) => x.toJson())),
    'CreatedBy': createdBy,
    'CreatedDate': createdDate,
    'Source': source,
    'CreatedTime': createdTime,
    'Photos': photos == null ? [] : List<dynamic>.from(photos!.map((x) => x)),
  };
}

class CleanedDatum {
  CleanedDatum({this.id, this.name, this.status});

  factory CleanedDatum.fromJson(Map<String, dynamic> json) =>
      CleanedDatum(id: json['Id'], name: json['Name'], status: json['Status']);

  final int? id;
  final String? name;
  final String? status;

  Map<String, dynamic> toJson() => {'Id': id, 'Name': name, 'Status': status};
}
