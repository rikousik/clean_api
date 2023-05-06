import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import 'clean_failure.dart';

enum RequestMethod { get, post, put, patch, delete }

class RequestData<T> extends Equatable {
  final RequestMethod method;
  final Uri uri;
  final dynamic body;
  final bool showLogs;
  final T Function(dynamic data) fromData;
  final Map<String, String>? headers;
  final Either<CleanFailure, T> Function(
      int statusCode, Map<String, dynamic> responseBody)? failureHandler;
  const RequestData({
    required this.method,
    required this.uri,
    this.body,
    this.showLogs = false,
    required this.fromData,
    this.headers,
    this.failureHandler,
  });

  String? get jsonEncodedBody => body != null
      ? body is String
          ? body
          : jsonEncode(body)
      : null;
  @override
  List<Object?> get props {
    return [
      method,
      uri,
      body,
      showLogs,
      fromData,
      headers,
      failureHandler,
    ];
  }
}
