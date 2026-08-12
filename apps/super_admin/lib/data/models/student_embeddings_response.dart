import 'dart:convert';

StudentEmbeddingsResponse studentEmbeddingsResponseFromJson(String str) =>
    StudentEmbeddingsResponse.fromJson(
      json.decode(str) as Map<String, dynamic>,
    );

class StudentEmbeddingsResponse {
  final bool err;
  final String message;
  final List<GetStuEmbeddingItem> data;

  StudentEmbeddingsResponse({
    required this.err,
    required this.message,
    required this.data,
  });

  factory StudentEmbeddingsResponse.fromJson(Map<String, dynamic> json) =>
      StudentEmbeddingsResponse(
        err: json["err"] as bool,
        message: json["message"] as String,
        data: List<GetStuEmbeddingItem>.from(
          (json["data"] as List<dynamic>).map(
            (x) => GetStuEmbeddingItem.fromJson(x as Map<String, dynamic>),
          ),
        ),
      );
}

class GetStuEmbeddingItem {
  final int id;
  final int studentId;
  final List<double> embedding;
  final String admissionNumber;
  final String name;
  final String section;
  final String standard;

  GetStuEmbeddingItem({
    required this.id,
    required this.studentId,
    required this.embedding,
    required this.admissionNumber,
    required this.name,
    required this.section,
    required this.standard,
  });

  factory GetStuEmbeddingItem.fromJson(Map<String, dynamic> json) =>
      GetStuEmbeddingItem(
        id: json["Id"] as int,
        studentId: json["StudentId"] as int,
        embedding: List<double>.from(
          (json["Embedding"] as List<dynamic>).map(
            (x) => (x as num).toDouble(),
          ),
        ),
        admissionNumber: json["AdmissionNumber"] as String,
        name: json["Name"] as String,
        section: json["Section"] as String,
        standard: json["Standard"] as String,
      );
}
