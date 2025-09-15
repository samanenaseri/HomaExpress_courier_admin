
import 'package:flutter/services.dart';

class PaymentService {
  static const MethodChannel _channel = MethodChannel('com.xc.pay_print/payment');

  // برای جلوگیری از چندبار ست شدن handler
  static bool _handlerAttached = false;

  Function(String status, String message)? onPaymentResult;

  PaymentService() {
    if (!_handlerAttached) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _handlerAttached = true;
    }
  }

  void setListener(Function(String, String) listener) {
    onPaymentResult = listener;
  }

  void removeListener() {
    onPaymentResult = null;
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        case 'onPaymentResult':
          final args = (call.arguments is Map)
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

  /// اگر SDK نیتیو مبلغ را به صورت واحد کوچکتر می‌خواهد، اینجا تبدیل کن (مثلاً *10 برای ریال).
  Future<bool> startPayment(double amount, {String? orderNumber}) async {
    try {
      final payload = <String, dynamic>{'amount': amount};
      if (orderNumber != null && orderNumber.isNotEmpty) {
        payload['orderNumber'] = orderNumber;
      }

      print('📤 Invoking native: startPayment $payload');
      await _channel.invokeMethod('startPayment', payload);
      return true;
    } on PlatformException catch (e) {
      print('❌ PlatformException starting payment: ${e.code} ${e.message}');
      onPaymentResult?.call('ERROR', e.message ?? 'PlatformException');
      return false;
    } catch (e) {
      print('❌ Error starting payment: $e');
      onPaymentResult?.call('ERROR', e.toString());
      return false;
    }
  }
}
