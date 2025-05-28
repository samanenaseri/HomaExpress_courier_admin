
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrintPage extends StatelessWidget {
  const PrintPage({super.key});

  static const platform = MethodChannel('com.xc.pay_print/print');

  Future<void> printSimple() async {
    try {
      final result = await platform.invokeMethod('print');
      print('Result: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> printReceipt() async {
    try {
      final result = await platform.invokeMethod('printReceipt', {
        'lines': ['Line 1', 'Line 2', 'Line 3'],
      });
      print('Result: $result');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: printSimple,
              child: const Text('Print Default Line'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: printReceipt,
              child: const Text('Print Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}