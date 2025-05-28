import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String status = args['status']?.toString() ?? '';
    final String message = args['message']?.toString() ?? '';
    final bool isSuccess = status.toLowerCase() == 'success';

    return Scaffold(
      appBar: AppBar(title: const Text("نتیجه پرداخت")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error,
                size: 80, color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(height: 20),
            Text(
              isSuccess ? "✅ پرداخت موفق" : "❌ پرداخت ناموفق",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.red,
              ),
              onPressed: () => Get.offAllNamed('/pickups'),
              child: const Text("بازگشت به سفارشات"),
            ),
          ],
        ),
      ),
    );
  }
}
