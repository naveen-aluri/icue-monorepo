// To parse this JSON data, do
//
//     final addVehicle = addVehicleFromJson(jsonString);

import 'dart:convert';

import 'vehicle_data.dart';

AddVehicle addVehicleFromJson(String str) =>
    AddVehicle.fromJson(json.decode(str));

String addVehicleToJson(AddVehicle data) => json.encode(data.toJson());

class AddVehicle {
  AddVehicle({
    this.source,
    this.organizationId,
    this.zoneId,
    this.branchId,
    required this.number,
    required this.fuelType,
    required this.companyClaimedMileage,
    required this.actualExpectedMileage,
    this.driverId,
    this.driverNumber,
    this.driverName,
    required this.airCondition,
    required this.chasisNumber,
    this.engineNumber,
    required this.year,
    this.rtaOfcName,
    required this.dateOfReg,
    this.model,
    required this.make,
    required this.capacity,
    this.serviceDate,
    this.colour,
    this.fireExtName,
    this.fireExtInstallDate,
    required this.fireExtExpiryDate,
    required this.firstAidKit,
    this.id,
    this.dashCamId,
  });

  factory AddVehicle.fromJson(Map<String, dynamic> json) => AddVehicle(
    id: json['Id'],
    dashCamId: json['DashcamId'],
    source: json['Source'],
    organizationId: json['OrganizationId'],
    zoneId: json['ZoneId'],
    branchId: json['BranchId'],
    number: json['Number'],
    fuelType: json['FuelType'],
    companyClaimedMileage: json['CompanyClaimedMileage'],
    actualExpectedMileage: json['ActualExpectedMileage'],
    driverId: json['DriverId'],
    driverNumber: json['DriverNumber'],
    driverName: json['DriverName'],
    airCondition: json['AirCondition'],
    chasisNumber: json['ChasisNumber'],
    engineNumber: json['EngineNumber'],
    year: json['Year'],
    rtaOfcName: json['RtaOfcName'],
    dateOfReg: json['DateOfReg'],
    model: json['Model'],
    make: json['Make'],
    capacity: json['Capacity'],
    serviceDate: json['ServiceDate'],
    colour: json['Colour'],
    fireExtName: json['FireExtName'],
    fireExtInstallDate: json['FireExtInstallDate'],
    fireExtExpiryDate: json['FireExtExpiryDate'],
    firstAidKit: json['FirstAidKit'] == null
        ? []
        : List<FirstAidKit>.from(
            json['FirstAidKit']!.map((x) => FirstAidKit.fromJson(x)),
          ),
  );

  final num actualExpectedMileage;
  final String airCondition;
  final num? branchId;
  final String capacity;
  final String chasisNumber;
  final String? colour;
  final num companyClaimedMileage;
  final String? dashCamId;
  final String dateOfReg;
  final num? driverId;
  final String? driverName;
  final num? driverNumber;
  final String? engineNumber;
  final String fireExtExpiryDate;
  final String? fireExtInstallDate;
  final String? fireExtName;
  final List<FirstAidKit> firstAidKit;
  final String fuelType;
  int? id;
  final String make;
  final String? model;
  final String number;
  final num? organizationId;
  final String? rtaOfcName;
  final String? serviceDate;
  final String? source;
  final String year;
  final num? zoneId;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'DashcamId': dashCamId,
    'Source': source,
    'OrganizationId': organizationId,
    'ZoneId': zoneId,
    'BranchId': branchId,
    'Number': number,
    'FuelType': fuelType,
    'CompanyClaimedMileage': companyClaimedMileage,
    'ActualExpectedMileage': actualExpectedMileage,
    'DriverId': driverId,
    'DriverNumber': driverNumber,
    'DriverName': driverName,
    'AirCondition': airCondition,
    'ChasisNumber': chasisNumber,
    'EngineNumber': engineNumber,
    'Year': year,
    'RtaOfcName': rtaOfcName,
    'DateOfReg': dateOfReg,
    'Model': model,
    'Make': make,
    'Capacity': capacity,
    'ServiceDate': serviceDate,
    'Colour': colour,
    'FireExtName': fireExtName,
    'FireExtInstallDate': fireExtInstallDate,
    'FireExtExpiryDate': fireExtExpiryDate,
    'FirstAidKit': List<dynamic>.from(firstAidKit.map((x) => x.toJson())),
  };
}
