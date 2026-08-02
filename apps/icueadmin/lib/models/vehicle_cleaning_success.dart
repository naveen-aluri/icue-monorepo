// To parse this JSON data, do
//
//     final vehicleCleaningSuccess = vehicleCleaningSuccessFromJson(jsonString);

import 'dart:convert';

VehicleCleaningSuccess vehicleCleaningSuccessFromJson(String str) =>
    VehicleCleaningSuccess.fromJson(json.decode(str));

String vehicleCleaningSuccessToJson(VehicleCleaningSuccess data) =>
    json.encode(data.toJson());

class VehicleCleaningSuccess {
  VehicleCleaningSuccess({
    required this.err,
    required this.message,
    required this.failedData,
    required this.totalCnt,
    required this.successCnt,
    required this.failedCnt,
  });

  factory VehicleCleaningSuccess.fromJson(Map<String, dynamic> json) =>
      VehicleCleaningSuccess(
        err: json['err'],
        message: json['message'],
        failedData: List<FailedDatum>.from(
          json['FailedData'].map((x) => FailedDatum.fromJson(x)),
        ),
        totalCnt: json['TotalCnt'],
        successCnt: json['SuccessCnt'],
        failedCnt: json['FailedCnt'],
      );

  final bool err;
  final int failedCnt;
  final List<FailedDatum> failedData;
  final String message;
  final int successCnt;
  final int totalCnt;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'FailedData': List<dynamic>.from(failedData.map((x) => x.toJson())),
    'TotalCnt': totalCnt,
    'SuccessCnt': successCnt,
    'FailedCnt': failedCnt,
  };
}

class FailedDatum {
  FailedDatum({
    required this.id,
    required this.vehicleNo,
    required this.cleanedDate,
    required this.isSuccess,
    required this.msg,
  });

  factory FailedDatum.fromJson(Map<String, dynamic> json) => FailedDatum(
    id: json['Id'],
    vehicleNo: json['VehicleNo'],
    cleanedDate: json['CleanedDate'],
    isSuccess: json['IsSuccess'],
    msg: json['Msg'],
  );

  final String cleanedDate;
  final int id;
  final bool isSuccess;
  final String msg;
  final String vehicleNo;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'VehicleNo': vehicleNo,
    'CleanedDate': cleanedDate,
    'IsSuccess': isSuccess,
    'Msg': msg,
  };
}
