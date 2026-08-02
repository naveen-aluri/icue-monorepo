// To parse this JSON data, do
//
//     final announcements = announcementsFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import '../utils/app_utils.dart';

List<Announcements> announcementsFromJson(String str) =>
    List<Announcements>.from(
      json.decode(str).map((x) => Announcements.fromJson(x)),
    );

String announcementsToJson(List<Announcements> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Announcements {
  Announcements({
    required this.announcementId,
    required this.id,
    required this.organizationId,
    required this.zoneIds,
    required this.branchIds,
    required this.studentIds,
    required this.title,
    required this.description,
    required this.announcementDate,
    required this.announcementTime,
    required this.expiryDate,
    required this.image,
    required this.createdBy,
    required this.createdDate,
    required this.isActive,
  });

  factory Announcements.fromJson(Map<String, dynamic> json) => Announcements(
    announcementId: json['_id'],
    id: json['Id'],
    organizationId: json['OrganizationId'],
    zoneIds: List<int>.from(json['ZoneIds'].map((x) => x)),
    branchIds: List<int>.from(json['BranchIds'].map((x) => x)),
    studentIds: List<dynamic>.from(
      removeNullValues(json['StudentIds']).map((x) => x),
    ),
    title: json['Title'],
    description: json['Description'],
    announcementDate: json['AnnouncementDate'],
    announcementTime: json['AnnouncementTime'],
    expiryDate: json['ExpiryDate'],
    image: json['Image'],
    createdBy: json['CreatedBy'],
    createdDate: DateTime.parse(json['CreatedDate']),
    isActive: json['IsActive'],
  );

  final String announcementDate;
  final String announcementId;
  final String announcementTime;
  final List<int> branchIds;
  final String createdBy;
  final DateTime createdDate;
  final String description;
  final String? expiryDate;
  final int id;
  final dynamic image;
  final bool isActive;
  final int organizationId;
  final List<dynamic> studentIds;
  final String title;
  final List<int> zoneIds;

  Map<String, dynamic> toJson() => {
    '_id': announcementId,
    'Id': id,
    'OrganizationId': organizationId,
    'ZoneIds': List<dynamic>.from(zoneIds.map((x) => x)),
    'BranchIds': List<dynamic>.from(branchIds.map((x) => x)),
    'StudentIds': List<dynamic>.from(studentIds.map((x) => x)),
    'Title': title,
    'Description': description,
    'AnnouncementDate': announcementDate,
    'AnnouncementTime': announcementTime,
    'ExpiryDate': expiryDate,
    'Image': image,
    'CreatedBy': createdBy,
    'CreatedDate': createdDate.toIso8601String(),
    'IsActive': isActive,
  };
}
