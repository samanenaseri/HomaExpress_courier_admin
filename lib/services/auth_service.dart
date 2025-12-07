import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  /// بقیهٔ APIهای پروژه‌ات روی http هستند؛ همسو نگه می‌دارم.
  final String baseUrl;
  final bool debug;

  /// اگر مسیر دقیق لاگین را می‌دانی، همین‌جا اول لیست بگذار (ایندکس صفر)
  final List<String> candidatePaths;

  AuthService({
    this.baseUrl = 'http://api.homaexpressco.com/api/v1/portal',
    this.debug = false,
    List<String>? candidatePaths,
  }) : candidatePaths = candidatePaths ??
      const [
        '/login',
        '/auth/login',
        '/portal/login',
        '/user/login',
        '/admin/login',
        '/signin',
      ];

  Future<String> login({
    required String username,
    required String password,
  }) async {
    http.Response? lastResp;
    Object? lastErr;

    for (final path in candidatePaths) {
      final url = Uri.parse('$baseUrl$path');

      // هر مسیر را با دو فرمت امتحان می‌کنیم: JSON و فرم
      final attempts = <_Attempt>[
        _Attempt(
          name: 'JSON $path (username)',
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'username': username, 'password': password}),
        ),
        _Attempt(
          name: 'JSON $path (email)',
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': username, 'password': password}),
        ),
        _Attempt(
          name: 'FORM $path (username)',
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'username': username, 'password': password},
        ),
        _Attempt(
          name: 'FORM $path (email)',
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'email': username, 'password': password},
        ),
      ];

      for (final att in attempts) {
        try {
          final resp = await http
              .post(url, headers: att.headers, body: att.body)
              .timeout(const Duration(seconds: 15));

          if (debug) {
            // ignore: avoid_print
            print('[AUTH][${att.name}] ${resp.statusCode} ${resp.body}');
          }

          // 200..299 → موفق
          if (resp.statusCode >= 200 && resp.statusCode < 300) {
            final data = _safeJson(resp.body);
            final token = data['token']?.toString() ??
                data['access_token']?.toString() ??
                data['data']?['token']?.toString() ??
                data['result']?['token']?.toString();
            if (token != null && token.isNotEmpty) {
              return token;
            }
            // اگر 200 اما توکن پیدا نشد، می‌ریم سراغ تلاش بعدی
            lastResp = resp;
            continue;
          }

          // 401 → یوزرنیم/پسورد غلط (مسیر درست است)
          if (resp.statusCode == 401) {
            throw AuthException('ایمیل یا کلمه عبور نادرست است.');
          }

          // 422 → پیام ولیدیشن
          if (resp.statusCode == 422) {
            final data = _safeJson(resp.body);
            final msg = _extractValidationMessage(data) ?? 'خطای اعتبارسنجی.';
            throw AuthException(msg);
          }

          // 404/405/… → احتمالاً مسیر/متد اشتباه؛ می‌ریم تلاش بعدی
          lastResp = resp;
        } on TimeoutException catch (e) {
          lastErr = e;
          if (debug) print('[AUTH][${att.name}] Timeout');
        } on SocketException catch (e) {
          lastErr = e;
          if (debug) print('[AUTH][${att.name}] SocketException $e');
        } catch (e) {
          lastErr = e;
          if (debug) print('[AUTH][${att.name}] Error $e');
        }
      }
    }

    // اگر هیچ‌کدام نگرفت:
    if (lastResp != null) {
      throw AuthException('خطا در ورود (کد ${lastResp!.statusCode}).');
    }
    if (lastErr != null) {
      throw AuthException('اتصال به سرور برقرار نشد.');
    }
    throw AuthException('ورود ناموفق بود.');
  }

  Map<String, dynamic> _safeJson(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map<String, dynamic>) return j;
      return <String, dynamic>{'raw': j};
    } catch (_) {
      return <String, dynamic>{'raw': body};
    }
  }

  String? _extractValidationMessage(Map<String, dynamic> data) {
    if (data['message'] is String && (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    if (data['errors'] is Map) {
      final errs = data['errors'] as Map;
      if (errs.isNotEmpty) {
        final first = errs.values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
        return first.toString();
      }
    }
    return null;
  }
}

class _Attempt {
  final String name;
  final Map<String, String> headers;
  final Object body;
  _Attempt({required this.name, required this.headers, required this.body});
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
