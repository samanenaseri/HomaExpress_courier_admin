// lib/services/payment_service.dart
import 'package:flutter/services.dart';

typedef PaymentResultCallback = void Function(Map<dynamic, dynamic> result);

class PaymentService {
  static const MethodChannel _channel = MethodChannel('com.xc.pay_print/payment');

  PaymentResultCallback? _listener;

  PaymentService() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  void setListener(PaymentResultCallback listener) {
    _listener = listener;
  }

  void removeListener() {
    _listener = null;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method == 'onPaymentResult') {
      final result = (call.arguments as Map).cast<dynamic, dynamic>();
      _listener?.call(result);
    }
  }

  /// پرسیدن از native آیا اپ پرداخت نصب است یا نه
  Future<bool> isPaymentAppInstalled() async {
    try {
      final bool installed = await _channel.invokeMethod('isPaymentAppInstalled', {});
      return installed;
    } on PlatformException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startPayment(
      int amount, {
        required String orderNumber,
        bool test = false,
        int? testAmount,
        bool forceTestSuccess = true,
        String? terminalId,
        String? merchantId,
        bool launchRealAppInTest = false,
      }) async {
    try {
      final args = <String, dynamic>{
        'amount': amount,
        'orderId': orderNumber,
        'test': test,
        if (testAmount != null) 'testAmount': testAmount,
        'forceTestSuccess': forceTestSuccess,
        if (terminalId != null) 'terminalId': terminalId,
        if (merchantId != null) 'merchantId': merchantId,
        'launchRealAppInTest': launchRealAppInTest,
      };

      await _channel.invokeMethod('startPayment', args);
      return true;
    } on PlatformException catch (e) {
      if (e.message != null && e.message!.isNotEmpty) {
        // show/return message if you want
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
