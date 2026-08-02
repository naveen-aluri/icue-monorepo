// To parse this JSON data, do
//
//     final driver = driverFromJson(jsonString);

import 'dart:convert';

List<Driver> driverFromJson(String str) =>
    List<Driver>.from(json.decode(str).map((x) => Driver.fromJson(x)));

String driverToJson(List<Driver> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Driver {
  Driver({
    required this.vehicles,
    required this.routes,
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.mobile,
    required this.dateOfBirth,
    required this.email,
    required this.designation,
    required this.licenceNumber,
    required this.licenceIssuedDate,
    required this.licenceExpiryDate,
    required this.licenceCopy,
    required this.healthRecord,
    required this.policeRecord,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.identificationId,
    required this.enforceChangePassword,
    required this.userType,
    this.dateOfJoining,
    this.idType,
    this.alternateNumber,
    this.drivingExperience,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    vehicles: List<String>.from(json['vehicles'].map((x) => x)),
    routes: List<String>.from(json['routes'].map((x) => x)),
    id: json['Id'],
    firstName: json['FirstName'],
    middleName: json['MiddleName'],
    lastName: json['LastName'],
    mobile: json['Mobile'],
    dateOfBirth: json['DateOfBirth'],
    email: json['Email'],
    designation: json['Designation'],
    licenceNumber: json['LicenceNumber'],
    licenceIssuedDate: json['LicenceIssuedDate'],
    licenceExpiryDate: json['LicenceExpiryDate'],
    licenceCopy: json['LicenceCopy'],
    healthRecord: json['HealthRecord'],
    policeRecord: json['PoliceRecord'],
    address: Address.fromJson(json['Address']),
    city: json['City'],
    state: json['State'],
    country: json['Country'],
    pincode: json['Pincode'],
    identificationId: json['IdentificationId'],
    enforceChangePassword: json['EnforceChangePassword'],
    userType: json['UserType'],
    dateOfJoining: json['DateOfJoining'],
    idType: json['IdType'],
    alternateNumber: json['AlternateNumber'],
    drivingExperience: json['DrivingExperience'],
  );

  final Address address;
  final int? alternateNumber;
  final String? city;
  final String? country;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final dynamic designation;
  final dynamic drivingExperience;
  final String? email;
  final bool enforceChangePassword;
  final String firstName;
  final dynamic healthRecord;
  final int id;
  final String? idType;
  final String? identificationId;
  final String? lastName;
  final dynamic licenceCopy;
  final String? licenceExpiryDate;
  final String? licenceIssuedDate;
  final String? licenceNumber;
  final String? middleName;
  final dynamic mobile;
  final dynamic pincode;
  final dynamic policeRecord;
  final List<String> routes;
  final String? state;
  final dynamic userType;
  final List<String> vehicles;

  Map<String, dynamic> toJson() => {
    'vehicles': List<dynamic>.from(vehicles.map((x) => x)),
    'routes': List<dynamic>.from(routes.map((x) => x)),
    'Id': id,
    'FirstName': firstName,
    'MiddleName': middleName,
    'LastName': lastName,
    'Mobile': mobile,
    'DateOfBirth': dateOfBirth,
    'Email': email,
    'Designation': designation,
    'LicenceNumber': licenceNumber,
    'LicenceIssuedDate': licenceIssuedDate,
    'LicenceExpiryDate': licenceExpiryDate,
    'LicenceCopy': licenceCopy,
    'HealthRecord': healthRecord,
    'PoliceRecord': policeRecord,
    'Address': address.toJson(),
    'City': city,
    'State': state,
    'Country': country,
    'Pincode': pincode,
    'IdentificationId': identificationId,
    'EnforceChangePassword': enforceChangePassword,
    'UserType': userType,
    'DateOfJoining': dateOfJoining,
    'IdType': idType,
    'AlternateNumber': alternateNumber,
    'DrivingExperience': drivingExperience,
  };
}

class Address {
  Address({required this.line1, required this.line2});

  factory Address.fromJson(Map<String, dynamic> json) =>
      Address(line1: json['Line1'], line2: json['Line2']);

  final String line1;
  final String? line2;

  Map<String, dynamic> toJson() => {'Line1': line1, 'Line2': line2};
}

AddDriver addDriverFromJson(String str) => AddDriver.fromJson(json.decode(str));

String addDriverToJson(AddDriver data) => json.encode(data.toJson());

class AddDriver {
  AddDriver({
    this.source,
    this.id,
    this.organizationId,
    this.zoneId,
    this.branchId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.alternateNumber,
    this.email,
    this.address,
    this.dateOfBirth,
    this.dateOfJoining,
    this.country,
    this.state,
    this.city,
    this.pincode,
    this.idType,
    this.drivingExperience,
    this.licenceNumber,
    this.licenceIssuedDate,
    this.licenceExpiryDate,
  });

  factory AddDriver.fromJson(Map<String, dynamic> json) => AddDriver(
    source: json['Source'],
    id: json['Id'],
    organizationId: json['OrganizationId'],
    zoneId: json['ZoneId'],
    branchId: json['BranchId'],
    firstName: json['FirstName'],
    middleName: json['MiddleName'],
    lastName: json['LastName'],
    mobile: json['Mobile'],
    alternateNumber: json['AlternateNumber'],
    email: json['Email'],
    address: json['Address'] == null ? null : Address.fromJson(json['Address']),
    dateOfBirth: json['DateOfBirth'],
    dateOfJoining: json['DateOfJoining'],
    country: json['Country'],
    state: json['State'],
    city: json['City'],
    pincode: json['Pincode'],
    idType: json['IdType'],
    drivingExperience: json['DrivingExperience'],
    licenceNumber: json['LicenceNumber'],
    licenceIssuedDate: json['LicenceIssuedDate'],
    licenceExpiryDate: json['LicenceExpiryDate'],
  );

  Address? address;
  String? alternateNumber;
  int? branchId;
  String? city;
  String? country;
  String? dateOfBirth;
  String? dateOfJoining;
  String? drivingExperience;
  String? email;
  String? firstName;
  int? id;
  String? idType;
  String? lastName;
  String? licenceExpiryDate;
  String? licenceIssuedDate;
  String? licenceNumber;
  String? middleName;
  int? mobile;
  int? organizationId;
  String? pincode;
  String? source;
  String? state;
  int? zoneId;

  Map<String, dynamic> toJson() => {
    'Source': source,
    'Id': id,
    'OrganizationId': organizationId,
    'ZoneId': zoneId,
    'BranchId': branchId,
    'FirstName': firstName,
    'MiddleName': middleName,
    'LastName': lastName,
    'Mobile': mobile,
    'AlternateNumber': alternateNumber,
    'Email': email,
    'Address': address?.toJson(),
    'DateOfBirth': dateOfBirth,
    'DateOfJoining': dateOfJoining,
    'Country': country,
    'State': state,
    'City': city,
    'Pincode': pincode,
    'IdType': idType,
    'DrivingExperience': drivingExperience,
    'LicenceNumber': licenceNumber,
    'LicenceIssuedDate': licenceIssuedDate,
    'LicenceExpiryDate': licenceExpiryDate,
  };
}
