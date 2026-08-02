// To parse this JSON data, do
//
//     final routes = routesFromJson(jsonString);

// ignore_for_file: join_return_with_assignment, unnecessary_lambdas, constant_identifier_names

import 'dart:convert';

import 'package:hive/hive.dart';

import 'vehicle_slots.dart';

part 'routes.g.dart';

Routes routesFromJson(String str) => Routes.fromJson(json.decode(str));

String routesToJson(Routes data) => json.encode(data.toJson());

class Routes {
  Routes({required this.err, required this.message, required this.route});

  factory Routes.fromJson(Map<String, dynamic> json) => Routes(
    err: json['err'],
    message: json['message'],
    route: List<Routee>.from(json['Route'].map((x) => Routee.fromJson(x))),
  );

  final bool err;
  final String message;
  final List<Routee> route;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'Route': List<dynamic>.from(route.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 7)
class Routee {
  Routee({
    required this.routeNo,
    required this.mode,
    required this.id,
    required this.points,
    this.vehicleNumber,
    this.routeStartTime,
  });

  factory Routee.fromJson(Map<String, dynamic> json) => Routee(
    vehicleNumber: json['VehicleNumber'],
    routeStartTime: json['RouteStartTime'],
    routeNo: json['RouteNo'],
    mode: modeValues.map[json['Mode']]!,
    id: json['Id'],
    points: json['Points'] == null
        ? []
        : List<Point>.from(json['Points'].map((x) => Point.fromJson(x))),
  );

  @HiveField(0)
  final int id;

  @HiveField(1)
  final Mode mode;

  @HiveField(2)
  final List<Point> points;

  @HiveField(3)
  final String routeNo;

  final String? routeStartTime;
  final String? vehicleNumber;

  Map<String, dynamic> toJson() => {
    'VehicleNumber': vehicleNumber,
    'RouteStartTime': routeStartTime,
    'RouteNo': routeNo,
    'Mode': modeValues.reverse[mode],
    'Id': id,
    'Points': List<dynamic>.from(points.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 9)
class Point {
  Point({required this.name, required this.studentIds});

  factory Point.fromJson(Map<String, dynamic> json) => Point(
    name: json['Name'],
    studentIds: List<int>.from(json['StudentIds'].map((x) => x)),
  );

  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<int> studentIds;

  Map<String, dynamic> toJson() => {
    'Name': name,
    'StudentIds': List<dynamic>.from(studentIds.map((x) => x)),
  };
}

@HiveType(typeId: 8)
enum Mode {
  @HiveField(0)
  DROP,
  @HiveField(1)
  PICKUP,
}

final modeValues = EnumValues({'Drop': Mode.DROP, 'Pickup': Mode.PICKUP});
