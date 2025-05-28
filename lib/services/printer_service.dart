import 'package:flutter/services.dart';

class PrinterService {
  static const MethodChannel _channel = MethodChannel('com.xc.pay_print/printer');

  Future<bool> printReceipt(List<String> lines) async {
    try {
      final bool result = await _channel.invokeMethod('printReceipt', {
        'lines': lines,
      });
      return result;
    } on PlatformException catch (e) {
      print('Error printing receipt: ${e.message}');
      return false;
    }
  }
} 