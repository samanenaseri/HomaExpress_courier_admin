
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homaexpress_courier_admin/services/printer_service.dart';

class PrintPage extends StatelessWidget {
  PrintPage({super.key});
  final List<String> receiptLines = [
    'HE68659031228',
    'هما اکسپرس',
    'Homa Express',
    'شعبه تهران',
    '----------------------------------------',
    'مشخصات فرستنده',
    'کد ملی: 0451186478',
    'فرستنده: Mohsen Jokar',
    'مبدا: ایران آذربایجان شرقی',
    'آدرس: تهران چهارراه استانبول روبه روی پاساژ پلاسکو پاساژ',
    'پروانه پلاک 272 کافه سیلور - Tehran - 1674956111',
    '----------------------------------------',
    'مشخصات گیرنده',
    'گیرنده: محمدرضا 2 گیرنده: محمدرضا 2',
    'میرزایی 2 میرزایی 2',
    'کد ملی: 0410990825',
    'مقصد: مالاوی - Chiradzulu',
    'Prizren - 3371785665 - ستی',
    '----------------------------------------',
    'مشخصات مرسوله',
    'وزن: 10 کیلوگرم',
    'ارزش اظهار شده: 100000',
    'تاریخ قبول: 28-12-1403',
    '----------------------------------------',
    'مرکز تماس: ۸۹۴۴',
    'www.homaexpressco.com',
  ];

  static const platform = MethodChannel('com.xc.pay_print/print');

  Future<void> printSimple() async {
    try {
      final result = await platform.invokeMethod('print');
      print('Result: $result');
    } catch (e) {
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Print'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final printerService = PrinterService();
                final success = await printerService.printReceipt(receiptLines);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt printed successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to print receipt')),
                  );
                }
              },
              icon: const Icon(Icons.print),
              label: const Text('Print Test Receipt'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/payment');
              },
              icon: const Icon(Icons.payment),
              label: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}