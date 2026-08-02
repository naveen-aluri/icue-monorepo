// To parse this JSON data, do
//
//     final country = countryFromJson(jsonString);

import 'dart:convert';

List<Country> countryFromJson(String str) =>
    List<Country>.from(json.decode(str).map((x) => Country.fromJson(x)));

String countryToJson(List<Country> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Country {
  Country({
    required this.countryId,
    required this.purpleId,
    required this.id,
    required this.name,
    required this.parentId,
    required this.type,
    required this.isActive,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    countryId: json['_id'],
    purpleId: json['id'],
    id: json['Id'],
    name: json['Name'],
    parentId: json['ParentId'],
    type: json['Type'],
    isActive: json['IsActive'],
  );

  final String countryId;
  final int id;
  final bool isActive;
  final String name;
  final String parentId;
  final String purpleId;
  final String type;

  Map<String, dynamic> toJson() => {
    '_id': countryId,
    'id': purpleId,
    'Id': id,
    'Name': name,
    'ParentId': parentId,
    'Type': type,
    'IsActive': isActive,
  };
}

List<Place> placeFromJson(String str) =>
    List<Place>.from(json.decode(str).map((x) => Place.fromJson(x)));

String placeToJson(List<Place> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Place {
  Place({
    required this.placeId,
    required this.purpleId,
    required this.name,
    required this.parentId,
    required this.type,
    required this.isActive,
    this.gst,
    this.cgst,
    this.sgst,
    this.igst,
    required this.id,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    placeId: json['_id'],
    purpleId: json['id'],
    name: json['Name'],
    parentId: json['ParentId'],
    type: json['Type'],
    isActive: json['IsActive'],
    gst: json['GST'],
    cgst: json['CGST'],
    sgst: json['SGST'],
    igst: json['IGST'],
    id: json['Id'],
  );

  final int? cgst;
  final int? gst;
  final int id;
  final int? igst;
  final bool isActive;
  final String name;
  final String parentId;
  final String placeId;
  final String purpleId;
  final int? sgst;
  final String type;

  Map<String, dynamic> toJson() => {
    '_id': placeId,
    'id': purpleId,
    'Name': name,
    'ParentId': parentId,
    'Type': type,
    'IsActive': isActive,
    'GST': gst,
    'CGST': cgst,
    'SGST': sgst,
    'IGST': igst,
    'Id': id,
  };
}
