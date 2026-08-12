class StudentPhotosResponse {
  final StudentMetadata metadata;
  final List<Student> data;
  final bool err;
  final String message;

  StudentPhotosResponse({
    required this.metadata,
    required this.data,
    required this.err,
    required this.message,
  });

  factory StudentPhotosResponse.fromJson(Map<String, dynamic> json) {
    return StudentPhotosResponse(
      metadata: StudentMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      data: (json['data'] as List<dynamic>)
          .map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
      err: json['err'] as bool,
      message: json['message'] as String,
    );
  }
}

class StudentMetadata {
  final int total;
  final int page;
  final int pageSize;

  StudentMetadata({
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory StudentMetadata.fromJson(Map<String, dynamic> json) {
    return StudentMetadata(
      total: json['total'] as int,
      page: json['page'] as int,
      pageSize: json['pagesize'] as int,
    );
  }
}

class Student {
  final int id;
  final String name;
  final String admissionNumber;
  final String standard;
  final String section;
  final String? photoUrl;

  Student({
    required this.id,
    required this.name,
    required this.admissionNumber,
    required this.standard,
    required this.section,
    this.photoUrl,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['Id'] as int,
      name: json['Name'] as String,
      admissionNumber: json['AdmissionNumber'] as String,
      standard: json['Standard'] as String,
      section: json['Section'] as String,
      photoUrl: json['PhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'AdmissionNumber': admissionNumber,
      'Standard': standard,
      'Section': section,
      if (photoUrl != null) 'PhotoUrl': photoUrl,
    };
  }
}
