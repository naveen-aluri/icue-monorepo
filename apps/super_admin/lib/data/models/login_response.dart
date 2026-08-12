class LoginResponse {
  final int id;
  final String name;
  final int organizationId;
  final int zoneId;
  final int branchId;
  final String sesid;
  final String token;

  LoginResponse({
    required this.id,
    required this.name,
    required this.organizationId,
    required this.zoneId,
    required this.branchId,
    required this.sesid,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['Id'] as int,
      name: json['Name'] as String,
      organizationId: json['OrganizationId'] as int,
      zoneId: json['ZoneId'] as int,
      branchId: json['BranchId'] as int,
      sesid: json['Sesid'] as String,
      token: json['Token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'OrganizationId': organizationId,
      'ZoneId': zoneId,
      'BranchId': branchId,
      'Sesid': sesid,
      'Token': token,
    };
  }
}
