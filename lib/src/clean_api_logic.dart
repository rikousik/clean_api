// ignore_for_file: no_leading_underscores_for_local_identifiers

part of '../clean_api.dart';

class CleanApi {
  final CleanLog log = CleanLog();
  late String _baseUrl;
  bool _showLogs = false;
  Map<String, String>? _token;
  Box? _cacheBox;
  late bool _enableDialogue;
  void setup(
      {required String baseUrl,
      bool showLogs = false,
      bool enableDialogue = true}) {
    log.init();
    _baseUrl = baseUrl;
    _showLogs = showLogs;
    _enableDialogue = enableDialogue;
  }

  void setToken(Map<String, String> token) => _token = token;
  void enableCache(Box box) => _cacheBox = box;

  String getBaseUrl() => _baseUrl;
  CleanApi._();

  static final CleanApi instance = CleanApi._();
  // factory CleanApi.instance() => _instance;

  // static CleanApi get instance => _instance;

  Map<String, String> header(bool withToken) {
    if (withToken) {
      return {
        'Content-Type': 'application/json',
        'Content': 'application/json',
        'Accept': 'application/json',
        if (_token != null) ..._token!
      };
    } else {
      return {
        'Content-Type': 'application/json',
        'Content': 'application/json',
        'Accept': 'application/json',
      };
    }
  }

  Future<Either<CleanFailure, T>> customUrlGet<T>({
    required T Function(dynamic data) fromData,
    bool? showLogs,
    required String url,
  }) async {
    final bool canPrint = showLogs ?? _showLogs;

    try {
      final Response _response = await http.get(
        Uri.parse(url),
      );

      log.printInfo(info: "request: ${_response.request}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode == 200) {
        final Map<String, dynamic> _regResponse = json
            .decode(utf8.decode(_response.bodyBytes)) as Map<String, dynamic>;
        _cacheBox?.put(url, _response.body);
        final T _typedResponse = fromData(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);

        return right(_typedResponse);
      } else {
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);
        return left(CleanFailure.withData(
            statusCode: _response.statusCode,
            enableDialogue: _enableDialogue,
            method: 'customUrlGet',
            tag: url,
            url: url,
            header: const {},
            body: const {},
            error: cleanJsonDecode(_response.body)));
      }
    } catch (e) {
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          method: 'customUrlGet',
          tag: url,
          url: url,
          header: const {},
          body: const {},
          error: e.toString()));
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
      {required T Function(dynamic data) fromData,
      bool? showLogs,
      required String endPoint}) {
    final bool canPrint = showLogs ?? _showLogs;
    try {
      String? body = _cacheBox?.get(endPoint) as String?;
      if (body != null && body.isNotEmpty) {
        log.printInfo(info: "body: $body", canPrint: canPrint);
        final Map<String, dynamic> _regResponse =
            cleanJsonDecode(body) as Map<String, dynamic>;
        final T _typedResponse = fromData(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);

        return right(_typedResponse);
      } else {
        log.printError(error: 'No cache available', canPrint: canPrint);
        return left(CleanFailure.withData(
            statusCode: -1,
            enableDialogue: _enableDialogue,
            method: 'getFromCache',
            tag: endPoint,
            url: "$_baseUrl$endPoint",
            header: const {},
            body: const {},
            error: 'No cache available'));
      }
    } catch (e) {
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          method: 'getFromCache',
          tag: endPoint,
          url: "$_baseUrl$endPoint",
          header: const {},
          body: const {},
          error: e.toString()));
    }
  }

  Future<Either<CleanFailure, T>> get<T>(
      {required T Function(dynamic data) fromData,
      required String endPoint,
      bool? showLogs,
      bool withToken = true,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = header(withToken);

    try {
      final Response _response = await http.get(
        Uri.parse("$_baseUrl$endPoint"),
        headers: _header,
      );

      return _handleResponse<T>(
          response: _response,
          endPoint: endPoint,
          fromData: fromData,
          failureHandler: failureHandler,
          canPrint: canPrint);
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);

      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          tag: endPoint,
          method: 'GET',
          url: "$_baseUrl$endPoint",
          header: _header,
          body: const {},
          error: e.toString()));
    }
  }

  Future<Either<CleanFailure, Response>> getResponse({
    required String endPoint,
    bool? showLogs,
    bool withToken = true,
  }) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = header(withToken);

    try {
      final Response _response = await http.get(
        Uri.parse("$_baseUrl$endPoint"),
        headers: _header,
      );

      log.printInfo(info: "request: ${_response.request}", canPrint: canPrint);
      log.printResponse(json: _response.body, canPrint: canPrint);

      if (_response.statusCode >= 200 && _response.statusCode <= 299) {
        log.printSuccess(
            msg: "response body: ${_response.body}", canPrint: canPrint);
        return right(_response);
      } else {
        log.printWarning(warn: "header: $_header", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${_response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${_response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${_response.statusCode}", canPrint: canPrint);

        return left(CleanFailure.withData(
            statusCode: _response.statusCode,
            tag: 'Response',
            method: 'GET',
            enableDialogue: _enableDialogue,
            url: "$_baseUrl$endPoint",
            header: _header,
            body: const {},
            error: cleanJsonDecode(_response.body)));
      }
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);

      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          tag: 'Response',
          method: 'GET',
          url: "$_baseUrl$endPoint",
          header: _header,
          body: const {},
          error: e.toString()));
    }
  }

  Future<Either<CleanFailure, T>> post<T>(
      {required T Function(dynamic data) fromData,
      required Map<String, dynamic>? body,
      bool? showLogs,
      required String endPoint,
      bool withToken = true,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler}) async {
    final bool canPrint = showLogs ?? _showLogs;

    if (body != null) {
      log.printInfo(info: "body: $body", canPrint: canPrint);
    }

    final Map<String, String> _header = header(withToken);

    try {
      final http.Response _response = await http.post(
        Uri.parse("$_baseUrl$endPoint"),
        body: body != null ? jsonEncode(body) : null,
        headers: _header,
      );
      return _handleResponse<T>(
          response: _response,
          endPoint: endPoint,
          fromData: fromData,
          failureHandler: failureHandler,
          canPrint: canPrint);
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);

      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);

      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          tag: endPoint,
          method: 'POST',
          url: "$_baseUrl$endPoint",
          header: _header,
          body: body ?? {'data': 'null'},
          error: e.toString()));
    }
  }

  Future<Either<CleanFailure, T>> put<T>(
      {required T Function(dynamic data) fromData,
      required Map<String, dynamic>? body,
      required String endPoint,
      bool? showLogs,
      bool withToken = true,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler}) async {
    final bool canPrint = showLogs ?? _showLogs;
    if (body != null) {
      log.printInfo(info: "body: $body", canPrint: canPrint);
    }
    final Map<String, String> _header = header(withToken);

    try {
      final http.Response _response = await http.put(
        Uri.parse("$_baseUrl$endPoint"),
        body: body != null ? jsonEncode(body) : null,
        headers: _header,
      );

      return _handleResponse<T>(
          response: _response,
          endPoint: endPoint,
          fromData: fromData,
          failureHandler: failureHandler,
          canPrint: canPrint);
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);

      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          tag: endPoint,
          method: 'PUT',
          url: "$_baseUrl$endPoint",
          header: _header,
          body: body ?? {"data": "null"},
          error: e.toString()));
    }
  }

  Future<Either<CleanFailure, T>> patch<T>(
      {required T Function(dynamic data) fromData,
      required Map<String, dynamic> body,
      required String endPoint,
      bool? showLogs,
      bool withToken = true,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = header(withToken);
    log.printInfo(info: "body: $body", canPrint: canPrint);
    try {
      final http.Response _response = await http.patch(
        Uri.parse("$_baseUrl$endPoint"),
        body: jsonEncode(body),
        headers: _header,
      );

      return _handleResponse<T>(
          response: _response,
          endPoint: endPoint,
          fromData: fromData,
          failureHandler: failureHandler,
          canPrint: canPrint);
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);

      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          tag: endPoint,
          method: 'PUT',
          url: "$_baseUrl$endPoint",
          header: _header,
          body: body,
          error: e.toString()));
    }
  }

  Future<Either<CleanFailure, T>> delete<T>(
      {required T Function(dynamic data) fromData,
      required String endPoint,
      Map<String, dynamic>? body,
      bool? showLogs,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      bool withToken = true}) async {
    final bool canPrint = showLogs ?? _showLogs;
    if (body != null) {
      log.printInfo(info: "body: $body", canPrint: canPrint);
    }
    final Map<String, String> _header = header(withToken);
    try {
      final Response _response = await http.delete(
        Uri.parse("$_baseUrl$endPoint"),
        body: body != null ? jsonEncode(body) : null,
        headers: _header,
      );

      return _handleResponse<T>(
          response: _response,
          endPoint: endPoint,
          fromData: fromData,
          failureHandler: failureHandler,
          canPrint: canPrint);
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: canPrint);
      log.printError(error: "error: ${e.toString()}", canPrint: canPrint);
      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          tag: endPoint,
          method: 'DELETE',
          url: "$_baseUrl$endPoint",
          header: _header,
          body: body ?? {},
          error: e.toString()));
    }
  }

  Either<CleanFailure, T> _handleResponse<T>(
      {required Response response,
      required String endPoint,
      Map<String, dynamic>? body,
      required T Function(dynamic data) fromData,
      required Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      required bool canPrint}) {
    log.printInfo(info: "request: ${response.request}", canPrint: canPrint);
    log.printResponse(json: response.body, canPrint: canPrint);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final _regResponse = cleanJsonDecode(response.body);

      try {
        final T _typedResponse = fromData(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: canPrint);
        return right(_typedResponse);
      } catch (e) {
        if (failureHandler != null) {
          return failureHandler(
            response.statusCode,
            cleanJsonDecode(response.body),
          );
        } else {
          log.printWarning(
              warn: "header: ${response.request?.headers}", canPrint: canPrint);
          log.printWarning(
              warn: "request: ${response.request}", canPrint: canPrint);

          log.printWarning(warn: "body: ${response.body}", canPrint: canPrint);
          log.printWarning(
              warn: "status code: ${response.statusCode}", canPrint: canPrint);
          return left(CleanFailure.withData(
              statusCode: response.statusCode,
              enableDialogue: _enableDialogue,
              tag: endPoint,
              method: response.request!.method,
              url: "$_baseUrl$endPoint",
              header: response.request?.headers ?? {},
              body: body ?? {},
              error: cleanJsonDecode(response.body)));
        }
      }
    } else {
      if (failureHandler != null) {
        return failureHandler(
          response.statusCode,
          cleanJsonDecode(response.body),
        );
      } else {
        log.printWarning(
            warn: "header: ${response.request?.headers}", canPrint: canPrint);
        log.printWarning(
            warn: "request: ${response.request}", canPrint: canPrint);

        log.printWarning(warn: "body: ${response.body}", canPrint: canPrint);
        log.printWarning(
            warn: "status code: ${response.statusCode}", canPrint: canPrint);
        return left(CleanFailure.withData(
            statusCode: response.statusCode,
            enableDialogue: _enableDialogue,
            tag: endPoint,
            method: response.request!.method,
            url: "$_baseUrl$endPoint",
            header: response.request?.headers ?? {},
            body: body ?? {},
            error: cleanJsonDecode(response.body)));
      }
    }
  }

  cleanJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      throw body;
    }
  }
}
