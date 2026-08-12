// To parse this JSON data, do
//
//     final standardModel = standardModelFromJson(jsonString);

import 'dart:convert';

List<StandardModel> standardModelFromJson(String str) =>
    List<StandardModel>.from(
      json.decode(str).map((x) => StandardModel.fromJson(x)),
    );

String standardModelToJson(List<StandardModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StandardModel {
  final int id;
  final String name;
  // final List<Section> sections;
  final String standardType;

  StandardModel({
    required this.id,
    required this.name,
    // required this.sections,
    required this.standardType,
  });

  factory StandardModel.fromJson(Map<String, dynamic> json) => StandardModel(
    id: json["Id"],
    name: json["Name"],
    // sections: List<Section>.from(
    //   json["Sections"].map((x) => Section.fromJson(x)),
    // ),
    standardType: json["StandardType"],
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    // "Sections": List<dynamic>.from(sections.map((x) => x.toJson())),
    "StandardType": standardType,
  };
}

class Section {
  final String name;
  final int id;
  final String uid;

  Section({required this.name, required this.id, required this.uid});

  factory Section.fromJson(Map<String, dynamic> json) =>
      Section(name: json["Name"], id: json["id"], uid: json["UID"]);

  Map<String, dynamic> toJson() => {"Name": name, "id": id, "UID": uid};
}
