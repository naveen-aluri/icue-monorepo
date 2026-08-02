// To parse this JSON data, do
//
//     final appSettings = appSettingsFromJson(jsonString);

import 'dart:convert';

AppSettings appSettingsFromJson(String str) =>
    AppSettings.fromJson(json.decode(str));

String appSettingsToJson(AppSettings data) => json.encode(data.toJson());

class AppSettings {
  AppSettings({required this.err, required this.message, required this.vhCnfg});

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    err: json['err'],
    message: json['message'],
    vhCnfg: json['VhCnfg'] == null ? null : VhCnfg.fromJson(json['VhCnfg']),
  );

  final bool err;
  final String message;
  final VhCnfg? vhCnfg;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'VhCnfg': vhCnfg?.toJson(),
  };
}

class VhCnfg {
  VhCnfg({
    required this.isUploadCleaningImage,
    required this.cleaningImageLimit,
    required this.isUploadComplaintImage,
    required this.complaintImageLimit,
  });

  factory VhCnfg.fromJson(Map<String, dynamic> json) => VhCnfg(
    isUploadCleaningImage: json['IsUploadCleaningImage'],
    cleaningImageLimit: json['CleaningImageLimit'],
    isUploadComplaintImage: json['IsUploadComplaintImage'],
    complaintImageLimit: json['ComplaintImageLimit'],
  );

  final int cleaningImageLimit;
  final int complaintImageLimit;
  final bool isUploadCleaningImage;
  final bool isUploadComplaintImage;

  Map<String, dynamic> toJson() => {
    'IsUploadCleaningImage': isUploadCleaningImage,
    'CleaningImageLimit': cleaningImageLimit,
    'IsUploadComplaintImage': isUploadComplaintImage,
    'ComplaintImageLimit': complaintImageLimit,
  };
}
