library clean_api;

import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_failure.dart';
export 'api_failure.dart';

class CleanApi {
  late String _baseUrl;
  Map<String, String>? _token;
  Box? _cacheBox;
  void setBaseUrl(String url) => _baseUrl = url;
  void setToken(Map<String, String> token) => _token = token;
  void enableCache(Box box) => _cacheBox = box;

  String getBaseUrl() => _baseUrl;
  CleanApi._();

  static final CleanApi _instance = CleanApi._();
  factory CleanApi.instance() => _instance;

  Future<Map<String, String>> header(bool withToken) async {
    if (withToken) {
      return {
        'Content-Type': 'application/json',
        'Content': 'application/json',
        if (_token != null) ..._token!
      };
    } else {
      return {
        'Content-Type': 'application/json',
        'Content': 'application/json',
      };
    }
  }

  Future<Either<ApiFailure, T>> get<T>(
      {required T Function(Map<String, dynamic> json) fromJson,
      required String endPoint,
      bool withToken = true}) async {
    final Map<String, String> _header = await header(withToken);

    try {
      final Response _response = await http.get(
        Uri.parse("$_baseUrl$endPoint"),
        headers: _header,
      );

      Logger().i(_response.body);
      Logger().wtf(_response.request);

      if (_response.statusCode == 200) {
        final Map<String, dynamic> _regResponse = json
            .decode(utf8.decode(_response.bodyBytes)) as Map<String, dynamic>;
        Logger(
          printer: PrettyPrinter(
            lineLength: 120, // width of the output
          ),
        ).d(_regResponse, 'Server Response');
        _cacheBox?.put(endPoint, _response.body);
        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e(_response.body);
        Logger().e(_response.statusCode);
        Logger().e(_response.request);
        Logger().e(await header(withToken));
        return left(
            ApiFailure(error: _response.body, type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);
      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }

  Future<Either<ApiFailure, T>> customUrlGet<T>({
    required T Function(Map<String, dynamic> json) fromJson,
    required String url,
  }) async {
    try {
      final Response _response = await http.get(
        Uri.parse(url),
      );

      Logger().i(_response.body);
      Logger().wtf(_response.request);

      if (_response.statusCode == 200) {
        final Map<String, dynamic> _regResponse = json
            .decode(utf8.decode(_response.bodyBytes)) as Map<String, dynamic>;
        _cacheBox?.put(url, _response.body);
        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e(_response.body);
        Logger().e(_response.statusCode);
        Logger().e(_response.request);
        // Logger().e(await header(withToken));
        return left(
            ApiFailure(error: _response.body, type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);
      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }

  void saveInCache<T>(
      {required Map<String, dynamic> data, required String endPoint}) {
    _cacheBox!.put(endPoint, jsonEncode(data));
  }

  Either<ApiFailure, T> getFromCache<T>(
      {required T Function(Map<String, dynamic> json) fromJson,
      required String endPoint}) {
    try {
      String? body = _cacheBox?.get(endPoint) as String?;
      if (body != null && body.isNotEmpty) {
        Logger().i(body);
        final Map<String, dynamic> _regResponse =
            jsonDecode(body) as Map<String, dynamic>;
        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e('No cache available');

        return left(ApiFailure(
            error: 'No cache available', type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);
      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }

  Future<Either<ApiFailure, T>> post<T>(
      {required T Function(Map<String, dynamic> json) fromJson,
      required Map<String, dynamic> body,
      required String endPoint,
      bool withToken = true}) async {
    final Map<String, String> _header = await header(withToken);
    Logger().i("header: $_header");
    Logger().i("header: $_header");
    body.remove('runtimeType');

    try {
      final http.Response _response = await http.post(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      Logger().i("postCall: ${jsonEncode(body)} header: $_header");
      Logger().i(_response.request);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body) as Map<String, dynamic>;

        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e(_response.request);
        Logger().e(_response.body);
        Logger().e(_response.statusCode);

        return left(
            ApiFailure(error: _response.body, type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);
      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }

  Future<Either<ApiFailure, T>> put<T>(
      {required T Function(Map<String, dynamic>? json) fromJson,
      required Map<String, dynamic> body,
      required String endPoint,
      bool withToken = true}) async {
    final Map<String, String> _header = await header(withToken);

    body.remove('runtimeType');

    try {
      final http.Response _response = await http.put(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      Logger().i("postCall: ${jsonEncode(body)} header: $_header");

      if (_response.statusCode == 200) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body) as Map<String, dynamic>;

        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e(_response.body);
        return left(
            ApiFailure(error: _response.body, type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);
      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }

  Future<Either<ApiFailure, T>> patch<T>(
      {required T Function(Map<String, dynamic>? json) fromJson,
      required Map<String, dynamic> body,
      required String endPoint,
      bool withToken = true}) async {
    final Map<String, String> _header = await header(withToken);

    body.remove('runtimeType');

    try {
      final http.Response _response = await http.patch(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      Logger().i("postCall: ${jsonEncode(body)} header: $_header");

      if (_response.statusCode == 200) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body) as Map<String, dynamic>;

        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e(_response.body);
        return left(
            ApiFailure(error: _response.body, type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);
      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }

  Future<Either<ApiFailure, T>> delete<T>(
      {required T Function(Map<String, dynamic> json) fromJson,
      required String endPoint,
      bool withToken = true}) async {
    final Map<String, String> _header = await header(withToken);
    _header.addAll({'Accept': '*/*'});
    try {
      final Response _response = await http.delete(
        Uri.parse("$_baseUrl$endPoint"),
        headers: _header,
      );
      Logger().i(_response.request);

      Logger().i(_response.body);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body.isNotEmpty ? _response.body : "{}")
                as Map<String, dynamic>;
        _cacheBox?.put(endPoint, _response.body);
        final T _typedResponse = fromJson(_regResponse);
        return right(_typedResponse);
      } else {
        Logger().e(_response.body);
        Logger().e(_response.statusCode);
        Logger().e(_response.request);
        return left(ApiFailure(
            error: _response.body + ' ' + _response.statusCode.toString(),
            type: T.runtimeType.toString()));
      }
    } catch (e) {
      Logger().e(e);

      return left(
          ApiFailure(error: e.toString(), type: T.runtimeType.toString()));
    }
  }
}
