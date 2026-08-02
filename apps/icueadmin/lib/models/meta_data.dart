import 'dart:convert';

Metadata metadataFromJson(String str) => Metadata.fromJson(json.decode(str));
String metadataToJson(Metadata data) => json.encode(data.toJson());

class Metadata {
  const Metadata({
    required this.total,
    required this.page,
    required this.pagesize,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pagesize: json['pagesize'] ?? 10,
    );
  }

  final int page;

  final int pagesize;

  final int total;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Metadata &&
        other.total == total &&
        other.page == page &&
        other.pagesize == pagesize;
  }

  @override
  int get hashCode => total.hashCode ^ page.hashCode ^ pagesize.hashCode;

  @override
  String toString() =>
      'Metadata(total: $total, page: $page, pagesize: $pagesize)';

  Map<String, dynamic> toJson() => {
    'total': total,
    'page': page,
    'pagesize': pagesize,
  };

  Metadata copyWith({int? total, int? page, int? pagesize}) {
    return Metadata(
      total: total ?? this.total,
      page: page ?? this.page,
      pagesize: pagesize ?? this.pagesize,
    );
  }
}
