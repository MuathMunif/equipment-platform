import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'platform_client.dart';
import 'localization.dart';

class ApiError implements Exception, LocaleApiError {
  final int status;
  final String code;
  @override
  String get localeCode => code;
  final String message;
  const ApiError(this.status, this.code, this.message);
  @override
  String toString() => message;
}

String requestKey() => List.generate(
  24,
  (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();
String todayRiyadh() => DateTime.now()
    .toUtc()
    .add(const Duration(hours: 3))
    .toIso8601String()
    .split('T')
    .first;
String normalizeDigits(String input) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  return input
      .split('')
      .map(
        (c) => arabic.contains(c)
            ? arabic.indexOf(c).toString()
            : persian.contains(c)
            ? persian.indexOf(c).toString()
            : c == '٫'
            ? '.'
            : c,
      )
      .join();
}

String? exactMoney(String input) {
  final value = normalizeDigits(input.trim());
  if (!RegExp(r'^(0|[1-9][0-9]{0,8})(\.[0-9]{1,2})?$').hasMatch(value)) {
    return null;
  }
  final parts = value.split('.');
  final result =
      '${parts.first}.${parts.length == 1 ? '00' : parts.last.padRight(2, '0')}';
  return result == '0.00' ? null : result;
}

class Api {
  final http.Client client;
  final String base;
  final bool persistNative;
  final Duration timeout;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? token;
  String? csrf;
  String? workspace;
  VoidCallback? expired;
  Api({
    http.Client? client,
    String? base,
    this.persistNative = true,
    this.timeout = const Duration(seconds: 30),
  }) : client = client ?? createClient(),
       base =
           base ??
           const String.fromEnvironment('API_BASE_URL', defaultValue: '') {
    if (this.base.isNotEmpty && !Uri.parse(this.base).hasScheme) {
      throw ArgumentError('Absolute API base URL required');
    }
  }
  String get baseUrl => base.isNotEmpty
      ? base
      : kIsWeb
      ? '${Uri.base.scheme}://${Uri.base.host}:8080/api/v1'
      : 'http://127.0.0.1:8080/api/v1';
  String scoped(String path) {
    if (workspace == null) {
      throw const ApiError(401, 'SESSION_REQUIRED', 'سجّل الدخول للمتابعة');
    }
    return '/workspaces/$workspace$path';
  }

  Future<void> restore() async {
    if (!kIsWeb && persistNative) {
      token = await _storage.read(key: 'equipment_dev_session');
    }
  }

  Future<void> setToken(String? value) async {
    token = value;
    if (!kIsWeb && persistNative) {
      if (value == null) {
        await _storage.delete(key: 'equipment_dev_session');
      } else {
        await _storage.write(key: 'equipment_dev_session', value: value);
      }
    }
  }

  Future<void> clear() async {
    csrf = null;
    workspace = null;
    await setToken(null);
  }

  Future<http.Response> send(
    String method,
    String path, {
    Object? body,
    String? key,
    Uint8List? bytes,
    String? type,
  }) async {
    final headers = <String, String>{
      'Content-Type': type ?? 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      'X-CSRF-Token': ?csrf,
      'Idempotency-Key': ?key,
    };
    try {
      final request = http.Request(method, Uri.parse('$baseUrl$path'))
        ..headers.addAll(headers);
      if (bytes != null) {
        request.bodyBytes = bytes;
      } else if (body != null) {
        request.body = jsonEncode(body);
      }
      final response = await (() async => http.Response.fromStream(
        await client.send(request),
      ))().timeout(timeout);
      if (response.statusCode >= 400) {
        var message = 'تعذر إكمال الطلب؛ أعد المحاولة';
        var code = 'REQUEST_FAILED';
        try {
          final error = jsonDecode(
            utf8.decode(response.bodyBytes),
          ) as Map<String, dynamic>;
          message = error['message'] as String? ?? message;
          code = error['code'] as String? ?? code;
        } catch (_) {}
        if (response.statusCode == 401 && path != '/auth/verify') {
          await clear();
          expired?.call();
        }
        throw ApiError(response.statusCode, code, message);
      }
      return response;
    } on ApiError {
      rethrow;
    } on TimeoutException {
      throw ApiError(
        0,
        'TIMEOUT',
        method == 'GET'
            ? 'استغرق تحميل البيانات وقتًا طويلًا؛ أعد المحاولة'
            : path.startsWith('/auth/')
            ? 'لم يصل رد التحقق؛ أعد المحاولة'
            : 'لم يصل تأكيد الحفظ؛ أعد المحاولة بالبيانات نفسها أو راجع السجل',
      );
    } catch (_) {
      throw const ApiError(
        0,
        'NETWORK',
        'تعذر الاتصال بالخادم؛ تحقق من تشغيله ثم أعد المحاولة',
      );
    }
  }

  Future<dynamic> json(
    String method,
    String path, {
    Object? body,
    String? key,
  }) async {
    final response = await send(method, path, body: body, key: key);
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<Map<String, dynamic>> updatePreferredLocale(
    String languageCode,
  ) async {
    if (!supportedLanguageCodes.contains(languageCode)) {
      throw ArgumentError.value(languageCode, 'languageCode');
    }
    final data = await json(
      'PUT',
      '/auth/me/locale',
      body: {'preferredLocale': languageCode},
    ) as Map<String, dynamic>;
    csrf = data['csrfToken'];
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final data = await json('GET', '/auth/me') as Map<String, dynamic>;
    csrf = data['csrfToken'];
    workspace = data['workspaces'][0]['id'];
    return data;
  }
}
