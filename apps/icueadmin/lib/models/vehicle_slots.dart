// To parse this JSON data, do
//
//     final vehicleSlots = vehicleSlotsFromJson(jsonString);

// ignore_for_file: join_return_with_assignment, unnecessary_lambdas

import 'dart:convert';

import 'routes.dart';

VehicleSlots vehicleSlotsFromJson(String str) =>
    VehicleSlots.fromJson(json.decode(str));

String vehicleSlotsToJson(VehicleSlots data) => json.encode(data.toJson());

class VehicleSlots {
  VehicleSlots({
    required this.totalSlots,
    required this.activeSlot,
    required this.vehiclesStarted,
    required this.vehiclesInProgress,
    required this.vehiclesNotStarted,
    required this.slotNames,
    required this.slot1NotStarted,
    required this.slot2NotStarted,
    required this.slot3NotStarted,
    required this.slot1InProgress,
    required this.slot2InProgress,
    required this.slot3InProgress,
    required this.slot1Completed,
    required this.slot2Completed,
    required this.slot3Completed,
  });

  factory VehicleSlots.fromJson(Map<String, dynamic> json) => VehicleSlots(
    totalSlots: json['TotalSlots'],
    activeSlot: json['ActiveSlot'],
    vehiclesStarted: json['VehiclesStarted'] == null
        ? []
        : List<dynamic>.from(json['VehiclesStarted']!.map((x) => x)),
    vehiclesInProgress: json['VehiclesInProgress'] == null
        ? []
        : List<dynamic>.from(json['VehiclesInProgress']!.map((x) => x)),
    vehiclesNotStarted: json['VehiclesNotStarted'] == null
        ? []
        : List<VehicleDetails>.from(
            json['VehiclesNotStarted']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slotNames: json['SlotNames'] == null
        ? []
        : List<SlotName>.from(
            json['SlotNames']!.map((x) => SlotName.fromJson(x)),
          ),
    slot1NotStarted: json['Slot1NotStarted'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot1NotStarted']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot2NotStarted: json['Slot2NotStarted'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot2NotStarted']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot3NotStarted: json['Slot3NotStarted'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot3NotStarted']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot1InProgress: json['Slot1InProgress'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot1InProgress']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot2InProgress: json['Slot2InProgress'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot2InProgress']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot3InProgress: json['Slot3InProgress'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot3InProgress']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot1Completed: json['Slot1Completed'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot1Completed']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot2Completed: json['Slot2Completed'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot2Completed']!.map((x) => VehicleDetails.fromJson(x)),
          ),
    slot3Completed: json['Slot3Completed'] == null
        ? []
        : List<VehicleDetails>.from(
            json['Slot3Completed']!.map((x) => VehicleDetails.fromJson(x)),
          ),
  );

  final String activeSlot;
  final List<VehicleDetails> slot1Completed;
  final List<VehicleDetails> slot1InProgress;
  final List<VehicleDetails> slot1NotStarted;
  final List<VehicleDetails> slot2Completed;
  final List<VehicleDetails> slot2InProgress;
  final List<VehicleDetails> slot2NotStarted;
  final List<VehicleDetails> slot3Completed;
  final List<VehicleDetails> slot3InProgress;
  final List<VehicleDetails> slot3NotStarted;
  final List<SlotName> slotNames;
  final int totalSlots;
  final List<dynamic> vehiclesInProgress;
  final List<VehicleDetails> vehiclesNotStarted;
  final List<dynamic> vehiclesStarted;

  Map<String, dynamic> toJson() => {
    'TotalSlots': totalSlots,
    'ActiveSlot': activeSlot,
    'VehiclesStarted': List<dynamic>.from(vehiclesStarted.map((x) => x)),
    'VehiclesInProgress': List<dynamic>.from(vehiclesInProgress.map((x) => x)),
    'VehiclesNotStarted': List<dynamic>.from(
      vehiclesNotStarted.map((x) => x.toJson()),
    ),
    'SlotNames': List<dynamic>.from(slotNames.map((x) => x.toJson())),
    'Slot1NotStarted': List<dynamic>.from(
      slot1NotStarted.map((x) => x.toJson()),
    ),
    'Slot2NotStarted': List<dynamic>.from(
      slot2NotStarted.map((x) => x.toJson()),
    ),
    'Slot3NotStarted': List<dynamic>.from(
      slot3NotStarted.map((x) => x.toJson()),
    ),
    'Slot1InProgress': List<dynamic>.from(
      slot1InProgress.map((x) => x.toJson()),
    ),
    'Slot2InProgress': List<dynamic>.from(
      slot2InProgress.map((x) => x.toJson()),
    ),
    'Slot3InProgress': List<dynamic>.from(
      slot3InProgress.map((x) => x.toJson()),
    ),
    'Slot1Completed': List<dynamic>.from(slot1Completed.map((x) => x.toJson())),
    'Slot2Completed': List<dynamic>.from(slot2Completed.map((x) => x.toJson())),
    'Slot3Completed': List<dynamic>.from(slot3Completed.map((x) => x.toJson())),
  };
}

class VehicleDetails {
  VehicleDetails({
    required this.vehicleNumber,
    required this.driverName,
    required this.driverNumber,
    required this.mode,
    required this.routeNo,
    required this.routeDetailsId,
    // required this.startPoint,
    // required this.endPoint,
    required this.routeStartTime,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) => VehicleDetails(
    vehicleNumber: json['VehicleNumber'],
    driverName: json['DriverName'],
    driverNumber: json['DriverNumber'],
    mode: modeValues.map[json['Mode']]!,
    routeNo: json['RouteNo'],
    routeDetailsId: json['RouteDetailsId'],
    // startPoint: json['StartPoint'],
    // endPoint: json['EndPoint'],
    routeStartTime: json['RouteStartTime'],
  );

  final String driverName;
  final dynamic driverNumber;
  // final String endPoint;
  final Mode mode;
  final int routeDetailsId;
  final String routeNo;
  final String routeStartTime;
  // final String startPoint;
  final String vehicleNumber;

  Map<String, dynamic> toJson() => {
    'VehicleNumber': vehicleNumber,
    'DriverName': driverName,
    'DriverNumber': driverNumber,
    'Mode': modeValues.reverse[mode],
    'RouteNo': routeNo,
    'RouteDetailsId': routeDetailsId,
    // 'StartPoint': startPoint,
    // 'EndPoint': endPoint,
    'RouteStartTime': routeStartTime,
  };
}

class SlotName {
  SlotName({required this.key, required this.value});

  factory SlotName.fromJson(Map<String, dynamic> json) =>
      SlotName(key: json['Key'], value: json['Value']);

  final String key;
  final String value;

  Map<String, dynamic> toJson() => {'Key': key, 'Value': value};
}

class EnumValues<T> {
  EnumValues(this.map);

  Map<String, T> map;
  late Map<T, String> reverseMap;

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
