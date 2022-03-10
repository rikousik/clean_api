part of '../clean_api.dart';

class CleanApi {
  final CleanLog log = CleanLog();
  late String _baseUrl;
  bool _showLogs = false;
  Map<String, String>? _token;
  Box? _cacheBox;
  void setup({required String baseUrl, showLogs = false}) {
    log.init();
    _baseUrl = baseUrl;
    _showLogs = showLogs;
  }

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

  Future<Either<CleanFailure, T>> customUrlGet<T>({
    required T Function(Map<String, dynamic> json) fromJson,
    bool? showLogs,
    required String url,
  }) async {
    final bool canPrint = showLogs ?? _showLogs;

    try {
      final Response _response = await http.get(
        Uri.parse(url),
      );

      log.printInfo(info: "request: ${_response.body}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode == 200) {
        final Map<String, dynamic> _regResponse = json
            .decode(utf8.decode(_response.bodyBytes)) as Map<String, dynamic>;
        _cacheBox?.put(url, _response.body);
        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);

        return right(_typedResponse);
      } else {
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(
            CleanFailure(error: _response.body, tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }

  void saveInCache<T>(
      {required Map<String, dynamic> data,
      required String endPoint,
      bool? showLogs}) {
    final bool canPrint = showLogs ?? _showLogs;

    try {
      _cacheBox!.put(endPoint, jsonEncode(data));
      log.printSuccess(msg: "saved data: $data", canPrint: canPrint);
    } catch (e) {
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
    }
  }

  Either<CleanFailure, T> getFromCache<T>(
      {required T Function(Map<String, dynamic> json) fromJson,
      bool? showLogs,
      required String endPoint}) {
    final bool canPrint = showLogs ?? _showLogs;

    try {
      String? body = _cacheBox?.get(endPoint) as String?;
      if (body != null && body.isNotEmpty) {
        log.printInfo(info: "body: $body", canPrint: canPrint);
        final Map<String, dynamic> _regResponse =
            jsonDecode(body) as Map<String, dynamic>;
        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);

        return right(_typedResponse);
      } else {
        log.printError(error: 'No cache available', canPrint: canPrint);
        return left(CleanFailure(
            error: 'No cache available', tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }

  Future<Either<CleanFailure, T>> get<T>(
      {required T Function(dynamic json) fromJson,
      required String endPoint,
      bool? showLogs,
      bool withToken = true}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = await header(withToken);

    try {
      final Response _response = await http.get(
        Uri.parse("$_baseUrl$endPoint"),
        headers: _header,
      );

      log.printInfo(info: "request: ${_response.body}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final dynamic _regResponse = json.decode(_response.body);

        _cacheBox?.put(endPoint, _response.body);
        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);
        return right(_typedResponse);
      } else {
        log.printWarning(warn: "header: $_header", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(
            CleanFailure(error: _response.body, tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);

      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }

  Future<Either<CleanFailure, T>> post<T>(
      {required T Function(dynamic json) fromJson,
      required Map<String, dynamic> body,
      bool? showLogs,
      required String endPoint,
      bool withToken = true}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = await header(withToken);

    try {
      final http.Response _response = await http.post(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      log.printInfo(info: "request: ${_response.body}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final _regResponse = jsonDecode(_response.body);

        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);
        return right(_typedResponse);
      } else {
        log.printWarning(warn: "header: $_header", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(
            CleanFailure(error: _response.body, tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);

      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }

  Future<Either<CleanFailure, T>> put<T>(
      {required T Function(Map<String, dynamic>? json) fromJson,
      required Map<String, dynamic> body,
      required String endPoint,
      bool? showLogs,
      bool withToken = true}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = await header(withToken);

    try {
      final http.Response _response = await http.put(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      log.printInfo(info: "request: ${_response.body}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body) as Map<String, dynamic>;

        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);
        return right(_typedResponse);
      } else {
        log.printWarning(warn: "header: $_header", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(
            CleanFailure(error: _response.body, tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }

  Future<Either<CleanFailure, T>> patch<T>(
      {required T Function(Map<String, dynamic>? json) fromJson,
      required Map<String, dynamic> body,
      required String endPoint,
      bool? showLogs,
      bool withToken = true}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = await header(withToken);

    try {
      final http.Response _response = await http.patch(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      log.printInfo(info: "request: ${_response.body}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body) as Map<String, dynamic>;

        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);
        return right(_typedResponse);
      } else {
        log.printWarning(warn: "header: $_header", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(
            CleanFailure(error: _response.body, tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }

  Future<Either<CleanFailure, T>> delete<T>(
      {required T Function(Map<String, dynamic> json) fromJson,
      required String endPoint,
      bool? showLogs,
      bool withToken = true}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = await header(withToken);
    _header.addAll({'Accept': '*/*'});
    try {
      final Response _response = await http.delete(
        Uri.parse("$_baseUrl$endPoint"),
        headers: _header,
      );
      log.printInfo(info: "request: ${_response.body}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        final Map<String, dynamic> _regResponse =
            jsonDecode(_response.body.isNotEmpty ? _response.body : "{}")
                as Map<String, dynamic>;
        _cacheBox?.put(endPoint, _response.body);
        final T _typedResponse = fromJson(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);
        return right(_typedResponse);
      } else {
        log.printWarning(warn: "header: $_header", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(CleanFailure(
            error: _response.body + ' ' + _response.statusCode.toString(),
            tag: T.runtimeType.toString()));
      }
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);

      return left(
          CleanFailure(error: e.toString(), tag: T.runtimeType.toString()));
    }
  }
}
