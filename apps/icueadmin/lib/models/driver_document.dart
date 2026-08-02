// To parse this JSON data, do
//
//     final driverDocument = driverDocumentFromJson(jsonString);

import 'dart:convert';

DriverDocument driverDocumentFromJson(String str) =>
    DriverDocument.fromJson(json.decode(str));

String driverDocumentToJson(DriverDocument data) => json.encode(data.toJson());

class DriverDocument {
  DriverDocument({
    required this.err,
    required this.message,
    required this.docs,
  });

  factory DriverDocument.fromJson(Map<String, dynamic> json) => DriverDocument(
    err: json['err'],
    message: json['message'],
    docs: Docs.fromJson(json['docs']),
  );

  final Docs docs;
  final bool err;
  final String message;

  Map<String, dynamic> toJson() => {
    'err': err,
    'message': message,
    'docs': docs.toJson(),
  };
}

class Docs {
  Docs({
    required this.recordId,
    required this.type,
    this.frontPhotoDocumentId,
    this.frontPhotoImageUrl,
    this.frontPhotoContentType,
    this.backPhotoImageUrl,
    this.backPhotoContentType,
    this.backPhotoDocumentId,
    this.docUrl,
    this.contentType,
    this.documentId,
  });

  factory Docs.fromJson(Map<String, dynamic> json) => Docs(
    recordId: json['RecordId'],
    type: json['Type'],
    frontPhotoDocumentId: json['FrontPhoto_DocumentId'],
    frontPhotoImageUrl: json['FrontPhoto_ImageUrl'],
    frontPhotoContentType: json['FrontPhoto_ContentType'],
    backPhotoImageUrl: json['BackPhoto_ImageUrl'],
    backPhotoContentType: json['BackPhoto_ContentType'],
    backPhotoDocumentId: json['BackPhoto_DocumentId'],
    docUrl: json['DocUrl'],
    contentType: json['ContentType'],
    documentId: json['DocumentId'],
  );

  final String? backPhotoContentType;
  final String? backPhotoDocumentId;
  final String? backPhotoImageUrl;
  final String? contentType;
  final String? docUrl;
  final String? documentId;
  final String? frontPhotoContentType;
  final String? frontPhotoDocumentId;
  final String? frontPhotoImageUrl;
  final int recordId;
  final String type;

  Map<String, dynamic> toJson() => {
    'RecordId': recordId,
    'Type': type,
    'FrontPhoto_DocumentId': frontPhotoDocumentId,
    'FrontPhoto_ImageUrl': frontPhotoImageUrl,
    'FrontPhoto_ContentType': frontPhotoContentType,
    'BackPhoto_ImageUrl': backPhotoImageUrl,
    'BackPhoto_ContentType': backPhotoContentType,
    'BackPhoto_DocumentId': backPhotoDocumentId,
    'DocUrl': docUrl,
    'ContentType': contentType,
    'DocumentId': documentId,
  };
}
