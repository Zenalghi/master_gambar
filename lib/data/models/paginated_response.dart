// File: lib/data/models/paginated_response.dart

class PaginatedResponse<T> {
  final List<T> data;
  final int total;

  PaginatedResponse({required this.data, required this.total});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List).map((item) => fromJsonT(item)).toList(),
      total: json['total'],
    );
  }
}
