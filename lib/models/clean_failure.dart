// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:clean_api/clean_api.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CleanFailure extends Equatable {
  final String tag;
  final String error;
  final bool _enableDialogue;
  final int statusCode;

  const CleanFailure(
      {required this.tag,
      required this.error,
      bool enableDialogue = true,
      this.statusCode = -1})
      : _enableDialogue = enableDialogue;

  CleanFailure copyWith({String? tag, String? error, int? statusCode}) {
    return CleanFailure(
        tag: tag ?? this.tag,
        error: error ?? this.error,
        statusCode: statusCode ?? this.statusCode);
  }

  factory CleanFailure.withData(
      {required String tag,
      required String url,
      required String method,
      required int statusCode,
      required Map<String, String> header,
      required Map<String, dynamic> body,
      bool enableDialogue = true,
      required dynamic error}) {
    final String _tag = tag == 'Type' ? url : tag;
    final Map<String, dynamic> _errorMap = {
      'url': url,
      'method': method,
      if (header.isNotEmpty) 'header': header,
      if (body.isNotEmpty) 'body': body,
      'error': error,
      if (statusCode > 0) 'status_code': statusCode
    };
    final encoder = JsonEncoder.withIndent(' ' * 2);
    // return encoder.convert(toJson());
    final String _errorStr = encoder.convert(_errorMap);
    return CleanFailure(
        tag: _tag,
        error: _errorStr,
        enableDialogue: enableDialogue,
        statusCode: statusCode);
  }
  factory CleanFailure.none() => const CleanFailure(tag: '', error: '');

  @override
  String toString() => 'CleanFailure(type: $tag, error: $error)';

  showDialogue(BuildContext context) {
    if (_enableDialogue) {
      CleanFailureDialogue.show(context, failure: this);
    } else {
      Logger.e(this);
    }
  }

  @override
  List<Object> get props => [tag, error];
}
