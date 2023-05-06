// ignore_for_file: no_leading_underscores_for_local_identifiers

part of '../clean_api.dart';

class CleanApi {
  final CleanLog log = CleanLog();
  late String _baseUrl;
  bool _showLogs = false;
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

  Map<String, String> _header = const {
    'Content-Type': 'application/json',
    'Content': 'application/json',
    'Accept': 'application/json',
  };
  Map<String, String> get header => _header;

  void setHeader(Map<String, String> header) =>
      _header = {..._header, ...header};

  String getBaseUrl() => _baseUrl;
  CleanApi._();

  static final CleanApi instance = CleanApi._();

  Future<Either<CleanFailure, T>> get<T>(
      {required T Function(dynamic data) fromData,
      required String endPoint,
      bool? showLogs,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      Map<String, String>? header}) async {
    final bool canPrint = showLogs ?? _showLogs;

    final Map<String, String> _header = header ?? this.header;
    final request = RequestData<T>(
      method: RequestMethod.get,
      uri: Uri.parse("$_baseUrl$endPoint"),
      showLogs: canPrint,
      fromData: fromData,
      headers: _header,
      failureHandler: failureHandler,
    );

    return fetch<T>(request: request);
  }

  Future<Either<CleanFailure, T>> post<T>(
      {required T Function(dynamic data) fromData,
      required Map<String, dynamic>? body,
      bool? showLogs,
      required String endPoint,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      Map<String, String>? header}) async {
    final bool canPrint = showLogs ?? _showLogs;

    if (body != null) {
      log.printInfo(info: "body: $body", canPrint: canPrint);
    }

    final Map<String, String> _header = header ?? this.header;
    final request = RequestData<T>(
        method: RequestMethod.post,
        uri: Uri.parse("$_baseUrl$endPoint"),
        showLogs: canPrint,
        fromData: fromData,
        headers: _header,
        failureHandler: failureHandler,
        body: body);

    return fetch<T>(request: request);
  }

  Future<Either<CleanFailure, T>> put<T>(
      {required T Function(dynamic data) fromData,
      required Map<String, dynamic>? body,
      required String endPoint,
      bool? showLogs,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      Map<String, String>? header}) async {
    final bool canPrint = showLogs ?? _showLogs;

    if (body != null) {
      log.printInfo(info: "body: $body", canPrint: canPrint);
    }

    final Map<String, String> _header = header ?? this.header;
    final request = RequestData<T>(
        method: RequestMethod.put,
        uri: Uri.parse("$_baseUrl$endPoint"),
        showLogs: canPrint,
        fromData: fromData,
        headers: _header,
        failureHandler: failureHandler,
        body: body);

    return fetch<T>(request: request);
  }

  Future<Either<CleanFailure, T>> patch<T>(
      {required T Function(dynamic data) fromData,
      required Map<String, dynamic> body,
      required String endPoint,
      bool? showLogs,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      Map<String, String>? header}) async {
    final bool canPrint = showLogs ?? _showLogs;

    log.printInfo(info: "body: $body", canPrint: canPrint);

    final Map<String, String> _header = header ?? this.header;
    final request = RequestData<T>(
        method: RequestMethod.patch,
        uri: Uri.parse("$_baseUrl$endPoint"),
        showLogs: canPrint,
        fromData: fromData,
        headers: _header,
        failureHandler: failureHandler,
        body: body);

    return fetch<T>(request: request);
  }

  Future<Either<CleanFailure, T>> delete<T>(
      {required T Function(dynamic data) fromData,
      required String endPoint,
      Map<String, dynamic>? body,
      bool? showLogs,
      Either<CleanFailure, T> Function(
              int statusCode, Map<String, dynamic> responseBody)?
          failureHandler,
      Map<String, String>? header}) async {
    final bool canPrint = showLogs ?? _showLogs;

    if (body != null) {
      log.printInfo(info: "body: $body", canPrint: canPrint);
    }

    final Map<String, String> _header = header ?? this.header;
    final request = RequestData<T>(
        method: RequestMethod.delete,
        uri: Uri.parse("$_baseUrl$endPoint"),
        showLogs: canPrint,
        fromData: fromData,
        headers: _header,
        failureHandler: failureHandler,
        body: body);

    return fetch<T>(request: request);
  }

  Either<CleanFailure, T> _handleResponse<T>({
    required Response response,
    required RequestData<T> request,
  }) {
    log.printInfo(
        info: "request: ${response.request}", canPrint: request.showLogs);
    log.printResponse(json: response.body, canPrint: request.showLogs);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      final _regResponse = cleanJsonDecode(response.body);

      try {
        final T _typedResponse = request.fromData(_regResponse);
        log.printSuccess(
            msg: "parsed data: $_typedResponse", canPrint: request.showLogs);
        return right(_typedResponse);
      } catch (e) {
        if (request.failureHandler != null) {
          return request.failureHandler!(
            response.statusCode,
            cleanJsonDecode(response.body),
          );
        } else {
          log.printWarning(
              warn: "header: ${response.request?.headers}",
              canPrint: request.showLogs);
          log.printWarning(
              warn: "request: ${response.request}", canPrint: request.showLogs);

          log.printWarning(
              warn: "body: ${response.body}", canPrint: request.showLogs);
          log.printWarning(
              warn: "status code: ${response.statusCode}",
              canPrint: request.showLogs);
          return left(CleanFailure.withData(
              statusCode: response.statusCode,
              request: request,
              enableDialogue: _enableDialogue,
              error: cleanJsonDecode(response.body)));
        }
      }
    } else {
      if (request.failureHandler != null) {
        return request.failureHandler!(
          response.statusCode,
          cleanJsonDecode(response.body),
        );
      } else {
        log.printWarning(
            warn: "header: ${response.request?.headers}",
            canPrint: request.showLogs);
        log.printWarning(
            warn: "request: ${response.request}", canPrint: request.showLogs);

        log.printWarning(
            warn: "body: ${response.body}", canPrint: request.showLogs);
        log.printWarning(
            warn: "status code: ${response.statusCode}",
            canPrint: request.showLogs);
        return left(CleanFailure.withData(
            statusCode: response.statusCode,
            enableDialogue: _enableDialogue,
            request: request,
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

  Future<http.Response> call({required RequestData request}) async {
    switch (request.method) {
      case RequestMethod.get:
        return http.get(
          request.uri,
          headers: request.headers,
        );
      case RequestMethod.post:
        return http.post(
          request.uri,
          body: request.jsonEncodedBody,
          headers: request.headers,
        );
      case RequestMethod.put:
        return http.put(
          request.uri,
          body: request.jsonEncodedBody,
          headers: request.headers,
        );
      case RequestMethod.patch:
        return http.patch(
          request.uri,
          body: request.jsonEncodedBody,
          headers: request.headers,
        );
      case RequestMethod.delete:
        return http.delete(
          request.uri,
          body: request.jsonEncodedBody,
          headers: request.headers,
        );
    }
  }

  Future<Either<CleanFailure, T>> fetch<T>(
      {required RequestData<T> request}) async {
    log.printInfo(info: "body: ${request.body}", canPrint: request.showLogs);
    try {
      final http.Response _response = await call(request: request);

      return _handleResponse<T>(
        response: _response,
        request: request,
      );
    } catch (e) {
      log.printError(error: "header: $_header", canPrint: request.showLogs);
      log.printError(
          error: "error: ${e.toString()}", canPrint: request.showLogs);

      return left(CleanFailure.withData(
          statusCode: -1,
          enableDialogue: _enableDialogue,
          request: request,
          error: e.toString()));
    }
  }
}
