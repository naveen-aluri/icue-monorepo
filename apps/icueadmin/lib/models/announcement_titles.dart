// To parse this JSON data, do
//
//     final announcementTitles = announcementTitlesFromJson(jsonString);

// ignore_for_file: unnecessary_lambdas

import 'dart:convert';

import 'package:hive/hive.dart';

part 'announcement_titles.g.dart';

AnnouncementTitles announcementTitlesFromJson(String str) =>
    AnnouncementTitles.fromJson(json.decode(str));

String announcementTitlesToJson(AnnouncementTitles data) =>
    json.encode(data.toJson());

class AnnouncementTitles {
  AnnouncementTitles({
    required this.err,
    required this.message,
    required this.data,
  });

  factory AnnouncementTitles.fromJson(Map<String, dynamic> json) =>
      AnnouncementTitles(
        err: json['err'],
        message: json['message'],
        data: json['data'] == null
            ? null
            : List<AnnouncementTitle>.from(
                json['data'].map((x) => AnnouncementTitle.fromJson(x)),
              ),
      );

  final List<AnnouncementTitle>? data;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'data': data == null
        ? null
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

@HiveType(typeId: 4)
class AnnouncementTitle {
  AnnouncementTitle({
    required this.type,
    required this.title,
    required this.descHeader,
    required this.descBody,
    required this.descFooter,
    required this.vars,
    required this.isActive,
  });

  factory AnnouncementTitle.fromJson(Map<String, dynamic> json) =>
      AnnouncementTitle(
        type: json['Type'],
        title: json['Title'],
        descHeader: json['DescHeader'],
        descBody: json['DescBody'],
        descFooter: json['DescFooter'],
        vars: List<String>.from(json['Vars']?.map((x) => x) ?? []),
        isActive: json['IsActive'],
      );

  @HiveField(0)
  final String descBody;

  @HiveField(1)
  final String descFooter;

  @HiveField(2)
  final String descHeader;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final int type;

  @HiveField(6)
  final List<String> vars;

  Map<String, dynamic> toJson() => {
    'Type': type,
    'Title': title,
    'DescHeader': descHeader,
    'DescBody': descBody,
    'DescFooter': descFooter,
    'Vars': List<dynamic>.from(vars.map((x) => x)),
    'IsActive': isActive,
  };
}
