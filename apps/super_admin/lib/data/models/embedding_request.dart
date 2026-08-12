class EmbeddingRequest {
  final int organizationId;
  final int zoneId;
  final int branchId;
  final List<StudentEmbedding> embeddings;

  EmbeddingRequest({
    required this.organizationId,
    required this.zoneId,
    required this.branchId,
    required this.embeddings,
  });

  Map<String, dynamic> toJson() {
    return {
      'OrganizationId': organizationId,
      'ZoneId': zoneId,
      'BranchId': branchId,
      'Embeddings': embeddings.map((e) => e.toJson()).toList(),
    };
  }
}

class StudentEmbedding {
  final int studentId;
  final String name;
  final String admissionNumber;
  final String standard;
  final int classId;
  final String section;
  final List<double> embedding;

  StudentEmbedding({
    required this.studentId,
    required this.name,
    required this.admissionNumber,
    required this.standard,
    required this.classId,
    required this.section,
    required this.embedding,
  });

  factory StudentEmbedding.fromJson(Map<String, dynamic> json) {
    return StudentEmbedding(
      studentId: (json['StudentId'] as num).toInt(),
      name: json['Name'] as String,
      admissionNumber: json['AdmissionNumber'] as String,
      standard: json['Standard'] as String,
      classId: (json['ClassId'] as num).toInt(),
      section: json['Section'] as String,
      embedding: (json['Embedding'] as List)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StudentId': studentId,
      'Name': name,
      'AdmissionNumber': admissionNumber,
      'Standard': standard,
      'ClassId': classId,
      'Section': section,
      'Embedding': embedding,
    };
  }
}
