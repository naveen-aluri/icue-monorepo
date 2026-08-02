// To parse this JSON data, do
//
//     final vehicle = vehicleFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'package:hive/hive.dart';
part 'vehicle.g.dart';

List<Vehicle> vehicleFromJson(String str) =>
    List<Vehicle>.from(json.decode(str).map((x) => Vehicle.fromJson(x)));

String vehicleToJson(List<Vehicle> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@HiveType(typeId: 10)
class Vehicle {
  Vehicle({
    required this.id,
    required this.number,
    required this.driverId,
    required this.driverName,
    required this.driverNumber,
    this.capacity,
    this.fuelType,
    this.price,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['Id'],
    number: json['Number'],
    driverId: json['DriverId'],
    driverName: json['DriverName'],
    driverNumber: json['DriverNumber'],
    capacity: json['Capacity'],
    fuelType: json['FuelType'],
    price: json['Price'],
  );

  @HiveField(0)
  final dynamic capacity;

  @HiveField(1)
  final num? driverId;

  @HiveField(2)
  final String driverName;

  @HiveField(3)
  final dynamic driverNumber;

  @HiveField(6)
  final dynamic fuelType;

  @HiveField(4)
  final int id;

  @HiveField(5)
  final String number;

  @HiveField(7)
  final String? price;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Number': number,
    'DriverId': driverId,
    'DriverName': driverName,
    'DriverNumber': driverNumber,
    'Capacity': capacity,
    'FuelType': fuelType,
    'Price': price,
  };
}

VehicleDetails vehicleDetailsFromJson(String str) =>
    VehicleDetails.fromJson(json.decode(str));

String vehicleDetailsToJson(VehicleDetails data) => json.encode(data.toJson());

@HiveType(typeId: 11)
class VehicleDetails {
  VehicleDetails({
    required this.vehicleDetailsId,
    required this.id,
    required this.organizationId,
    required this.zoneId,
    required this.branchId,
    required this.number,
    required this.driverId,
    required this.driverName,
    required this.driverNumber,
    required this.vendorId,
    required this.make,
    required this.model,
    this.colour,
    required this.year,
    required this.chasisNumber,
    this.insuranceNumber,
    this.insuredDate,
    this.insuranceExpiryDate,
    this.insuranceCopy,
    required this.rcExpiryDate,
    this.serviceDate,
    required this.capacity,
    required this.status,
    required this.isActive,
    this.lastUpdatedOn,
    this.updatedBy,
    required this.carrierId,
    required this.dashcamId,
    required this.isEnabledBluetoothDevice,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) => VehicleDetails(
    vehicleDetailsId: json['_id'],
    id: json['Id'],
    organizationId: json['OrganizationId'],
    zoneId: json['ZoneId'],
    branchId: json['BranchId'],
    number: json['Number'],
    driverId: json['DriverId'],
    driverName: json['DriverName'],
    driverNumber: json['DriverNumber'],
    vendorId: json['VendorId'],
    make: json['Make'],
    model: json['Model'],
    colour: json['Colour'],
    year: json['Year'],
    chasisNumber: json['ChasisNumber'],
    insuranceNumber: json['InsuranceNumber'],
    insuredDate: json['InsuredDate'],
    insuranceExpiryDate: json['InsuranceExpiryDate'],
    insuranceCopy: json['InsuranceCopy'],
    rcExpiryDate: json['RCExpiryDate'],
    serviceDate: json['ServiceDate'],
    capacity: json['Capacity'],
    status: json['Status'],
    isActive: json['IsActive'],
    lastUpdatedOn: json['LastUpdatedOn'] == null
        ? null
        : DateTime.parse(json['LastUpdatedOn']),
    updatedBy: json['UpdatedBy'],
    carrierId: json['CarrierId'],
    dashcamId: json['DashcamId'],
    isEnabledBluetoothDevice: json['IsEnabledBluetoothDevice'],
  );

  @HiveField(0)
  final int branchId;

  @HiveField(1)
  final dynamic capacity;

  @HiveField(2)
  final dynamic carrierId;

  @HiveField(3)
  final String chasisNumber;

  @HiveField(4)
  final String? colour;

  @HiveField(5)
  final dynamic dashcamId;

  @HiveField(6)
  final int driverId;

  @HiveField(7)
  final String driverName;

  @HiveField(8)
  final int driverNumber;

  @HiveField(9)
  final int id;

  @HiveField(10)
  final dynamic insuranceCopy;

  @HiveField(11)
  final String? insuranceExpiryDate;

  @HiveField(12)
  final String? insuranceNumber;

  @HiveField(13)
  final String? insuredDate;

  @HiveField(14)
  final bool isActive;

  @HiveField(15)
  final dynamic isEnabledBluetoothDevice;

  @HiveField(16)
  final DateTime? lastUpdatedOn;

  @HiveField(17)
  final String make;

  @HiveField(18)
  final String model;

  @HiveField(19)
  final String number;

  @HiveField(20)
  final int organizationId;

  @HiveField(21)
  final String rcExpiryDate;

  @HiveField(22)
  final String? serviceDate;

  @HiveField(23)
  final String status;

  @HiveField(24)
  final String? updatedBy;

  @HiveField(25)
  final dynamic vehicleDetailsId;

  @HiveField(26)
  final dynamic vendorId;

  @HiveField(27)
  final String year;

  @HiveField(28)
  final int zoneId;

  Map<String, dynamic> toJson() => {
    '_id': vehicleDetailsId,
    'Id': id,
    'OrganizationId': organizationId,
    'ZoneId': zoneId,
    'BranchId': branchId,
    'Number': number,
    'DriverId': driverId,
    'DriverName': driverName,
    'DriverNumber': driverNumber,
    'VendorId': vendorId,
    'Make': make,
    'Model': model,
    'Colour': colour,
    'Year': year,
    'ChasisNumber': chasisNumber,
    'InsuranceNumber': insuranceNumber,
    'InsuredDate': insuredDate,
    'InsuranceExpiryDate': insuranceExpiryDate,
    'InsuranceCopy': insuranceCopy,
    'RCExpiryDate': rcExpiryDate,
    'ServiceDate': serviceDate,
    'Capacity': capacity,
    'Status': status,
    'IsActive': isActive,
    'LastUpdatedOn': lastUpdatedOn?.toIso8601String(),
    'UpdatedBy': updatedBy,
    'CarrierId': carrierId,
    'DashcamId': dashcamId,
    'IsEnabledBluetoothDevice': isEnabledBluetoothDevice,
  };
}
