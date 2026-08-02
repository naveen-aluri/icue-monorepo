// To parse this JSON data, do
//
//     final vehicleData = vehicleDataFromJson(jsonString);

// ignore_for_file: constant_identifier_names

import 'dart:convert';

List<VehicleData> vehicleDataFromJson(String str) => List<VehicleData>.from(
  json.decode(str).map((x) => VehicleData.fromJson(x)),
);

String vehicleDataToJson(List<VehicleData> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VehicleData {
  VehicleData({
    this.routes,
    this.id,
    this.number,
    this.driverId,
    this.driverName,
    this.driverNumber,
    this.capacity,
    this.dashcamId,
    this.isEnabledBluetoothDevice,
    this.colour,
    this.vendorId,
    this.make,
    this.airCondition,
    this.model,
    this.year,
    this.chasisNumber,
    this.insuranceCopy,
    this.serviceDate,
    this.companyClaimedMileage,
    this.actualExpectedMileage,
    this.fuelType,
    this.insuranceNumber,
    this.insuredDate,
    this.insuranceExpiryDate,
    this.rcNumber,
    this.rcStartDate,
    this.rcExpiryDate,
    this.fitnessNumber,
    this.fitnessStartDate,
    this.fitnessExpiryDate,
    this.roadTaxNumber,
    this.roadTaxStartDate,
    this.roadTaxExpiryDate,
    this.pollutionExpiryDate,
    this.permitNumber,
    this.permitStartDate,
    this.permitExpiryDate,
    this.pollutionNumber,
    this.pollutionStartDate,
    this.engineNumber,
    this.rtaOfcName,
    this.dateOfReg,
    this.fireExtName,
    this.fireExtInstallDate,
    this.fireExtExpiryDate,
    this.firstAidKit,
  });

  factory VehicleData.fromJson(Map<String, dynamic> json) => VehicleData(
    routes: json['routes'] == null
        ? []
        : List<String>.from(json['routes']!.map((x) => x)),
    id: json['Id'],
    number: json['Number'],
    driverId: json['DriverId'],
    driverName: json['DriverName'],
    driverNumber: json['DriverNumber'],
    capacity: json['Capacity'],
    dashcamId: json['DashcamId'],
    isEnabledBluetoothDevice: json['IsEnabledBluetoothDevice'],
    colour: json['Colour'],
    vendorId: json['VendorId'],
    make: json['Make'],
    airCondition: json['AirCondition'],
    model: json['Model'],
    year: json['Year'],
    chasisNumber: json['ChasisNumber'],
    insuranceCopy: json['InsuranceCopy'],
    serviceDate: json['ServiceDate'],
    companyClaimedMileage: json['CompanyClaimedMileage'],
    actualExpectedMileage: json['ActualExpectedMileage'],
    fuelType: json['FuelType'],
    insuranceNumber: json['InsuranceNumber'],
    insuredDate: json['InsuredDate'],
    insuranceExpiryDate: json['InsuranceExpiryDate'],
    rcNumber: json['RCNumber'],
    rcStartDate: json['RCStartDate'],
    rcExpiryDate: json['RCExpiryDate'],
    fitnessNumber: json['FitnessNumber'],
    fitnessStartDate: json['FitnessStartDate'],
    fitnessExpiryDate: json['FitnessExpiryDate'],
    roadTaxNumber: json['RoadTaxNumber'],
    roadTaxStartDate: json['RoadTaxStartDate'],
    roadTaxExpiryDate: json['RoadTaxExpiryDate'],
    pollutionExpiryDate: json['PollutionExpiryDate'],
    permitNumber: json['PermitNumber'],
    permitStartDate: json['PermitStartDate'],
    permitExpiryDate: json['PermitExpiryDate'],
    pollutionNumber: json['PollutionNumber'],
    pollutionStartDate: json['PollutionStartDate'],
    engineNumber: json['EngineNumber'],
    rtaOfcName: json['RtaOfcName'],
    dateOfReg: json['DateOfReg'],
    fireExtName: json['FireExtName'],
    fireExtInstallDate: json['FireExtInstallDate'],
    fireExtExpiryDate: json['FireExtExpiryDate'],
    firstAidKit: json['FirstAidKit'] == null
        ? []
        : List<FirstAidKit>.from(
            json['FirstAidKit']!.map((x) => FirstAidKit.fromJson(x)),
          ),
  );

  final dynamic actualExpectedMileage;
  final String? airCondition;
  final dynamic capacity;
  final String? chasisNumber;
  final String? colour;
  final dynamic companyClaimedMileage;
  final String? dashcamId;
  final String? dateOfReg;
  final int? driverId;
  final String? driverName;
  final dynamic driverNumber;
  final String? engineNumber;
  final String? fireExtExpiryDate;
  final String? fireExtInstallDate;
  final String? fireExtName;
  final List<FirstAidKit>? firstAidKit;
  final String? fitnessExpiryDate;
  final String? fitnessNumber;
  final String? fitnessStartDate;
  final String? fuelType;
  final int? id;
  final dynamic insuranceCopy;
  final String? insuranceExpiryDate;
  final String? insuranceNumber;
  final String? insuredDate;
  final bool? isEnabledBluetoothDevice;
  final String? make;
  final String? model;
  final String? number;
  final String? permitExpiryDate;
  final String? permitNumber;
  final String? permitStartDate;
  final String? pollutionExpiryDate;
  final String? pollutionNumber;
  final String? pollutionStartDate;
  final String? rcExpiryDate;
  final String? rcNumber;
  final String? rcStartDate;
  final String? roadTaxExpiryDate;
  final String? roadTaxNumber;
  final String? roadTaxStartDate;
  final List<String>? routes;
  final String? rtaOfcName;
  final String? serviceDate;
  final dynamic vendorId;
  final String? year;

  Map<String, dynamic> toJson() => {
    'routes': routes == null ? [] : List<dynamic>.from(routes!.map((x) => x)),
    'Id': id,
    'Number': number,
    'DriverId': driverId,
    'DriverName': driverName,
    'DriverNumber': driverNumber,
    'Capacity': capacity,
    'DashcamId': dashcamId,
    'IsEnabledBluetoothDevice': isEnabledBluetoothDevice,
    'Colour': colour,
    'VendorId': vendorId,
    'Make': make,
    'AirCondition': airCondition,
    'Model': model,
    'Year': year,
    'ChasisNumber': chasisNumber,
    'InsuranceCopy': insuranceCopy,
    'ServiceDate': serviceDate,
    'CompanyClaimedMileage': companyClaimedMileage,
    'ActualExpectedMileage': actualExpectedMileage,
    'FuelType': fuelType,
    'InsuranceNumber': insuranceNumber,
    'InsuredDate': insuredDate,
    'InsuranceExpiryDate': insuranceExpiryDate,
    'RCNumber': rcNumber,
    'RCStartDate': rcStartDate,
    'RCExpiryDate': rcExpiryDate,
    'FitnessNumber': fitnessNumber,
    'FitnessStartDate': fitnessStartDate,
    'FitnessExpiryDate': fitnessExpiryDate,
    'RoadTaxNumber': roadTaxNumber,
    'RoadTaxStartDate': roadTaxStartDate,
    'RoadTaxExpiryDate': roadTaxExpiryDate,
    'PollutionExpiryDate': pollutionExpiryDate,
    'PermitNumber': permitNumber,
    'PermitStartDate': permitStartDate,
    'PermitExpiryDate': permitExpiryDate,
    'PollutionNumber': pollutionNumber,
    'PollutionStartDate': pollutionStartDate,
    'EngineNumber': engineNumber,
    'RtaOfcName': rtaOfcName,
    'DateOfReg': dateOfReg,
    'FireExtName': fireExtName,
    'FireExtInstallDate': fireExtInstallDate,
    'FireExtExpiryDate': fireExtExpiryDate,
    'FirstAidKit': firstAidKit == null
        ? []
        : List<dynamic>.from(firstAidKit!.map((x) => x.toJson())),
  };
}

class FirstAidKit {
  FirstAidKit({this.id, this.medicineDetails, this.medicineExpiryDate});

  factory FirstAidKit.fromJson(Map<String, dynamic> json) => FirstAidKit(
    id: json['Id'],
    medicineDetails: json['MedicineDetails'],
    medicineExpiryDate: json['MedicineExpiryDate'],
  );

  final int? id;
  String? medicineDetails;
  String? medicineExpiryDate;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'MedicineDetails': medicineDetails,
    'MedicineExpiryDate': medicineExpiryDate,
  };
}
