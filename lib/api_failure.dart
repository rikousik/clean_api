import 'dart:convert';

import 'package:equatable/equatable.dart';

class ApiFailure extends Equatable {
  final String type;
  final String error;

  const ApiFailure({
    required this.type,
    required this.error,
  });

  ApiFailure copyWith({
    String? type,
    String? error,
  }) {
    return ApiFailure(
      type: type ?? this.type,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'error': error,
    };
  }

  factory ApiFailure.fromMap(Map<String, dynamic> map) {
    return ApiFailure(
      type: map['type'] ?? '',
      error: map['error'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiFailure.fromJson(String source) =>
      ApiFailure.fromMap(json.decode(source));

  @override
  String toString() => 'ApiFailure(type: $type, error: $error)';

  @override
  List<Object> get props => [type, error];
}
