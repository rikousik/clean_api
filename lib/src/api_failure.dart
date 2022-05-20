import 'dart:convert';

import 'package:equatable/equatable.dart';

class CleanFailure extends Equatable {
  final String tag;
  final String error;

  const CleanFailure({
    required this.tag,
    required this.error,
  });

  CleanFailure copyWith({
    String? tag,
    String? error,
  }) {
    return CleanFailure(
      tag: tag ?? this.tag,
      error: error ?? this.error,
    );
  }

  factory CleanFailure.withData(
      {required String tag,
      required String url,
      required String method,
      required Map<String, String> header,
      required Map<String, dynamic> body,
      required dynamic error}) {
    final String _tag = tag == 'Type' ? url : tag;
    final Map<String, dynamic> _errorMap = {
      'url': url,
      'method': method,
      if (header.isNotEmpty) 'header': header,
      if (body.isNotEmpty) 'body': body,
      'error': error
    };
    final encoder = JsonEncoder.withIndent(' ' * 2);
    // return encoder.convert(toJson());
    final String _errorStr = encoder.convert(_errorMap);
    return CleanFailure(tag: _tag, error: _errorStr);
  }
  factory CleanFailure.none() => const CleanFailure(tag: '', error: '');

  @override
  String toString() => 'CleanFailure(type: $tag, error: $error)';

  @override
  List<Object> get props => [tag, error];
}
