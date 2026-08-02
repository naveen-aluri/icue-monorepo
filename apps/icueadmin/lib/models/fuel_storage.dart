import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
part 'fuel_storage.g.dart';

FuelStorage fuelStorageFromJson(String str) =>
    FuelStorage.fromJson(json.decode(str));

String fuelStorageToJson(FuelStorage data) => json.encode(data.toJson());

class FuelStorage {
  FuelStorage({
    required this.err,
    required this.message,
    this.toFill,
    required this.data,
  });

  factory FuelStorage.fromJson(Map<String, dynamic> json) => FuelStorage(
    err: json['err'],
    message: json['message'],
    toFill: json['toFill'],
    data: json['data'] == null
        ? []
        : List<Storage>.from(json['data'].map((x) => Storage.fromJson(x))),
  );

  List<Storage> data;
  bool err;
  String message;
  bool? toFill;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'toFill': toFill,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 20)
class Storage {
  Storage({required this.type, required this.items});

  factory Storage.fromJson(Map<String, dynamic> json) => Storage(
    type: json['Type'],
    items: List<StorageItem>.from(
      json['Items'].map((x) => StorageItem.fromJson(x)),
    ),
  );

  @HiveField(0)
  List<StorageItem> items;

  @HiveField(1)
  String type;

  Map<String, dynamic> toJson() => {
    'Type': type,
    'Items': List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 21)
class StorageItem {
  StorageItem({
    required this.name,
    required this.capacity,
    this.fuelType,
    required this.fuelPrice,
    this.type,
  });

  factory StorageItem.fromJson(Map<String, dynamic> json) => StorageItem(
    name: json['Name'],
    capacity: json['Capacity'],
    fuelType: json['FuelType'],
    fuelPrice: json['FuelPrice'],
  );

  @HiveField(0)
  int capacity;

  @HiveField(1)
  String? fuelPrice;

  @HiveField(2)
  String? fuelType;

  @HiveField(3)
  String name;

  @HiveField(4)
  String? type;

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Capacity': capacity,
    'FuelType': fuelType,
    'FuelPrice': fuelPrice,
  };
}
