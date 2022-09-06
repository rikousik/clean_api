import 'package:equatable/equatable.dart';

class CleanResponse extends Equatable {
  final int statusCode;
  final dynamic data;
  final Map<String, String> header;
  const CleanResponse({
    required this.statusCode,
    required this.data,
    required this.header,
  });

  @override
  String toString() =>
      'CleanResponse(statusCode: $statusCode, body: $data, header: $header)';

  @override
  List<Object> get props => [statusCode, data, header];

  CleanResponse copyWith({
    int? statusCode,
    dynamic body,
    Map<String, String>? header,
  }) {
    return CleanResponse(
      statusCode: statusCode ?? this.statusCode,
      data: body ?? data,
      header: header ?? this.header,
    );
  }
}
