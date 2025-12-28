// lib/services/payment_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef PaymentResultCallback = void Function(Map<String, dynamic> result);

class PaymentService {
  static const MethodChannel _channel =
  MethodChannel('com.xc.pay_print/payment');

  PaymentResultCallback? _listener;

  PaymentService() {
    // یک بار هندلر را ست می‌کنیم
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  void setListener(PaymentResultCallback listener) {
    _listener = listener;
  }

  void removeListener() {
    _listener = null;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    // if (kDebugMode) {
    //   debugPrint('XC_DEBUG 4) method = ${call.method}');
    //   debugPrint('XC_DEBUG 4) arguments = ${call.arguments}');
    // }

    if (call.method == 'onPaymentResult') {
      final args = call.arguments;
      late final Map<String, dynamic> result;

      if (args is Map) {
        // Map<dynamic,dynamic> → Map<String,dynamic>
        result = args.map(
              (key, value) => MapEntry(key.toString(), value),
        );
      } else if (args is String) {
        result = <String, dynamic>{'raw': args};
      } else {
        result = <String, dynamic>{'raw': args?.toString()};
      }

      // if (kDebugMode) {
      //   debugPrint('XC_DEBUG 4.1) calling listener with result = $result');
      // }

      final listener = _listener;
      if (listener != null) {
        listener(result);
      } else {
        // if (kDebugMode) {
        //   debugPrint('XC_DEBUG 4.2) listener is null, dropping result');
        // }
      }
    } else {
      // if (kDebugMode) {
      //   debugPrint('XC_DEBUG 4.X) unexpected method: ${call.method}');
      // }
    }
  }

  /// چک می‌کند اپ پرداخت نصب است یا نه
  Future<bool> isPaymentAppInstalled() async {
    try {
      final installed =
      await _channel.invokeMethod<bool>('isPaymentAppInstalled');
      return installed ?? false;
    } on PlatformException catch (e) {
      // if (kDebugMode) {
      //   debugPrint('isPaymentAppInstalled PlatformException: $e');
      // }
      return false;
    } catch (e) {
      // if (kDebugMode) {
      //   debugPrint('isPaymentAppInstalled error: $e');
      // }
      return false;
    }
  }

  /// شروع پرداخت روی TechPay
  Future<bool> startPayment(
      int amount, {
        required String orderNumber,
        String? terminalId,
        String? merchantId,
      }) async {
    try {
      final args = <String, dynamic>{
        'amount': amount.toDouble(), // MainActivity به صورت Double می‌خواند
        'orderId': orderNumber,
        if (terminalId != null) 'terminalId': terminalId,
        if (merchantId != null) 'merchantId': merchantId,
      };

      // if (kDebugMode) {
      //   debugPrint('XC_DEBUG 4.startPayment args = $args');
      // }

      await _channel.invokeMethod('startPayment', args);
      return true;
    } catch (e) {
      // if (kDebugMode) {
      //   debugPrint('startPayment error: $e');
      // }
      return false;
    }
  }
}
