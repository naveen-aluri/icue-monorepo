// To parse this JSON data, do
//
//     final vehicleSlotsModified = vehicleSlotsModifiedFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'vehicle_slots.dart';

VehicleSlotsModified vehicleSlotsModifiedFromJson(String str) =>
    VehicleSlotsModified.fromJson(json.decode(str));

String vehicleSlotsModifiedToJson(VehicleSlotsModified data) =>
    json.encode(data.toJson());

class VehicleSlotsModified {
  VehicleSlotsModified({
    required this.slots,
    required this.status,
    required this.activeSlot,
  });

  factory VehicleSlotsModified.fromJson(Map<String, dynamic> json) =>
      VehicleSlotsModified(
        slots: List<SlotName>.from(
          json['slots'].map((x) => SlotName.fromJson(x)),
        ),
        status: VehicleStatus.fromJson(json['status']),
        activeSlot: json['activeSlot'],
      );

  final List<SlotName> slots;
  final VehicleStatus status;
  final String activeSlot;

  Map<String, dynamic> toJson() => {
    'slots': List<dynamic>.from(slots.map((x) => x.toJson())),
    'status': status.toJson(),
    'ActiveSlot': activeSlot,
  };
}

class VehicleStatus {
  VehicleStatus({
    required this.slot1,
    required this.slot2,
    required this.slot3,
  });

  factory VehicleStatus.fromJson(Map<String, dynamic> json) => VehicleStatus(
    slot1: Slot1Class.fromJson(json['Slot1']),
    slot2: Slot1Class.fromJson(json['Slot2']),
    slot3: Slot1Class.fromJson(json['Slot3']),
  );

  final Slot1Class slot1;
  final Slot1Class slot2;
  final Slot1Class slot3;

  Map<String, dynamic> toJson() => {
    'Slot1': slot1.toJson(),
    'Slot2': slot2.toJson(),
    'Slot3': slot3.toJson(),
  };
}

class Slot1Class {
  Slot1Class({
    required this.notStarted,
    required this.inprogress,
    required this.completed,
  });

  factory Slot1Class.fromJson(Map<String, dynamic> json) => Slot1Class(
    notStarted: List<VehicleDetails>.from(
      json['notStarted'].map((x) => VehicleDetails.fromJson(x)),
    ),
    inprogress: List<VehicleDetails>.from(
      json['inprogress'].map((x) => VehicleDetails.fromJson(x)),
    ),
    completed: List<VehicleDetails>.from(
      json['completed'].map((x) => VehicleDetails.fromJson(x)),
    ),
  );

  final List<VehicleDetails> completed;
  final List<VehicleDetails> inprogress;
  final List<VehicleDetails> notStarted;

  Map<String, dynamic> toJson() => {
    'notStarted': List<dynamic>.from(notStarted.map((x) => x.toJson())),
    'inprogress': List<dynamic>.from(inprogress.map((x) => x.toJson())),
    'completed': List<dynamic>.from(completed.map((x) => x.toJson())),
  };
}
