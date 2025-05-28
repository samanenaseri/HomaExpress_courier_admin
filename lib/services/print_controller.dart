import 'package:flutter/services.dart';

class PrintController {
  static const platform = MethodChannel('com.xc.pay_print/channel');

  Future<void> printReceipt() async {
    try {
      final result = await platform.invokeMethod('print');
      print('Print result: $result');
    } on PlatformException catch (e) {
      print('Error calling native print: ${e.message}');
    }
  }
}