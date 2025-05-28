import 'package:flutter/services.dart';

class PaymentService {
  static const MethodChannel _channel = MethodChannel('com.xc.pay_print/payment');

  Function(String status, String message)? onPaymentResult;

  PaymentService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  void setListener(Function(String, String) listener) {
    onPaymentResult = listener;
  }

  void removeListener() {
    onPaymentResult = null;
  }


  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      if (call.method == 'onPaymentResult') {
        final status = call.arguments['status']?.toString() ?? 'unknown';
        final message = call.arguments['message']?.toString() ?? 'No message';
        print("📥 Received from native: $status - $message");
        onPaymentResult?.call(status, message);
      } else {
        print("⚠️ Unknown method received: ${call.method}");
      }
    } catch (e) {
      print("❌ Error in _handleMethodCall: $e");
    }
  }

  Future<bool> startPayment(double amount) async {
    try {
      print("📤 Invoking native payment with amount: $amount");
      await _channel.invokeMethod('startPayment', {'amount': amount});
      return true;
    } on PlatformException catch (e) {
      print('❌ Error starting payment: ${e.message}');
      return false;
    }
  }
}
