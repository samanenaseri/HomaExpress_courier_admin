import 'dart:async';
import 'package:flutter/services.dart';

class PaymentService {
  static const MethodChannel _channel = MethodChannel('com.xc.pay_print/payment');

  static bool _handlerAttached = false;
  Function(String status, String message)? onPaymentResult;

  PaymentService() {
    if (!_handlerAttached) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _handlerAttached = true;
    }
  }

  void setListener(Function(String, String) listener) => onPaymentResult = listener;
  void removeListener() => onPaymentResult = null;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onPaymentResult':
          final Map<String, dynamic> args = (call.arguments is Map)
              ? Map<String, dynamic>.from(call.arguments as Map)
              : <String, dynamic>{'raw': call.arguments};

          final status  = args['status']?.toString()  ?? 'unknown';
          final message = args['message']?.toString() ?? 'No message';

          print('📥 onPaymentResult: status=$status, message=$message, args=$args');
          onPaymentResult?.call(status, message);
          break;

        default:
          print('⚠️ Unknown method from native: ${call.method} | args=${call.arguments}');
      }
    } catch (e, st) {
      print('❌ Error in _handleMethodCall: $e\n$st');
    }
  }

  Future<bool> startPayment(
      int amount, {
        String? orderNumber,
        bool test = false,
      }) async {
    try {
      final payload = <String, dynamic>{
        'amount': amount,
        'test': test,            // اگر اپ مقصد کلید دیگری می‌خواهد، این را تغییر بده
      };
      if (orderNumber != null && orderNumber.isNotEmpty) {
        payload['orderNumber'] = orderNumber;
      }

      print('📤 Invoking native: startPayment $payload');

      // اگر نیتیو پاسخی همگام برگرداند:
      final dynamic res = await _channel
          .invokeMethod('startPayment', payload)
          .timeout(const Duration(seconds: 60));

      if (res is Map) {
        final status  = res['status']?.toString()  ?? 'unknown';
        final message = res['message']?.toString() ?? '';
        print('↩️ sync payment result from native: $res');
        onPaymentResult?.call(status, message);
      }

      return true;
    } on MissingPluginException catch (e) {
      // ⛔️ دیگر به listener سیگنال نمی‌دهیم؛ فقط false برمی‌گردانیم
      print('❌ MissingPluginException: $e');
      return false;
    } on PlatformException catch (e) {
      print('❌ PlatformException starting payment: ${e.code} ${e.message}');
      return false;
    } on TimeoutException catch (e) {
      print('❌ Timeout invoking native: $e');
      return false;
    } catch (e) {
      print('❌ Error starting payment: $e');
      return false;
    }
  }
}
