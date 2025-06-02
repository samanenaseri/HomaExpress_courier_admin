import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String status = args['status']?.toString() ?? 'unknown';
    final String message = args['message']?.toString() ?? 'بدون پیام';

    final bool isSuccess = status == 'success';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                  size: 100,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  isSuccess ? 'پرداخت موفق بود' : 'پرداخت ناموفق بود',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Get.back(), // یا مسیر دلخواه
                  child: const Text('بازگشت'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
