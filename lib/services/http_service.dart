import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  final http.Client _client = http.Client();
  final Map<String, String> _cookieStore = {};
  static const _timeout = Duration(seconds: 30);

  Future<Response<T>> get<T>(
      String url, {
        Map<String, String>? headers,
        Map<String, String>? cookies,
        bool freshSession = false,
        required T Function(dynamic json) fromJson,
      }) =>
      _send<T>(
        'GET',
        url,
        headers: headers,
        cookies: cookies,
        freshSession: freshSession,
        fromJson: fromJson,
      );

  Future<Response<T>> post<T>(
      String url, {
        Object? payload,
        Map<String, String>? headers,
        Map<String, String>? cookies,
        bool freshSession = false,
        required T Function(dynamic json) fromJson,
      }) =>
      _send<T>(
        'POST',
        url,
        payload: payload,
        headers: headers,
        cookies: cookies,
        freshSession: freshSession,
        fromJson: fromJson,
      );

  Future<Response<T>> put<T>(
      String url, {
        Object? payload,
        Map<String, String>? headers,
        Map<String, String>? cookies,
        bool freshSession = false,
        required T Function(dynamic json) fromJson,
      }) =>
      _send<T>(
        'PUT',
        url,
        payload: payload,
        headers: headers,
        cookies: cookies,
        freshSession: freshSession,
        fromJson: fromJson,
      );

  Future<Response<T>> delete<T>(
      String url, {
        Map<String, String>? headers,
        Map<String, String>? cookies,
        bool freshSession = false,
        required T Function(dynamic json) fromJson,
      }) =>
      _send<T>(
        'DELETE',
        url,
        headers: headers,
        cookies: cookies,
        freshSession: freshSession,
        fromJson: fromJson,
      );

  Future<Response<T>> _send<T>(
      String method,
      String url, {
        Object? payload,
        Map<String, String>? headers,
        Map<String, String>? cookies,
        bool freshSession = false,
        required T Function(dynamic json) fromJson,
      }) async {
    final client = freshSession ? http.Client() : _client;
    final uri = Uri.parse(url);

    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers,
    };

    final mergedCookies = <String, String>{
      if (!freshSession) ..._cookieStore,
      ...?cookies,
    };

    if (mergedCookies.isNotEmpty) {
      requestHeaders['Cookie'] =
          mergedCookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }

    late http.Response response;

    switch (method) {
      case 'POST':
        response = await client
            .post(uri,
            headers: requestHeaders,
            body: payload != null ? jsonEncode(payload) : null)
            .timeout(_timeout);
        break;
      case 'PUT':
        response = await client
            .put(uri,
            headers: requestHeaders,
            body: payload != null ? jsonEncode(payload) : null)
            .timeout(_timeout);
        break;
      case 'DELETE':
        response = await client
            .delete(uri, headers: requestHeaders)
            .timeout(_timeout);
        break;
      default:
        response = await client
            .get(uri, headers: requestHeaders)
            .timeout(_timeout);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'HTTP ${response.statusCode}',
        uri,
      );
    }

    _captureCookies(response.headers);

    final body = response.body.isNotEmpty
        ? fromJson(jsonDecode(response.body))
        : null;

    return Response<T>(
      body: body,
      headers: response.headers,
    );
  }

  void _captureCookies(Map<String, String> headers) {
    final setCookie = headers['set-cookie'];
    if (setCookie == null) return;

    for (final cookie in setCookie.split(',')) {
      final parts = cookie.split(';').first.split('=');
      if (parts.length == 2) {
        _cookieStore[parts[0].trim()] = parts[1].trim();
      }
    }
  }

  String? getCookie(Map<String, String> headers, String name) {
    final setCookie = headers['set-cookie'];
    if (setCookie == null) return null;

    for (final cookie in setCookie.split(',')) {
      final parts = cookie.split(';').first.split('=');
      if (parts.length == 2 && parts[0].trim() == name) {
        return parts[1].trim();
      }
    }
    return null;
  }
}

/// Nested response type to keep it truly "single class"
class Response<T> {
  final T? body;
  final Map<String, String> headers;

  Response({
    required this.body,
    required this.headers,
  });

  List<String>? get setCookies =>
      headers['set-cookie']?.split(',');
}
