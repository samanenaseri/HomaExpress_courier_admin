import 'package:flutter/material.dart';

class PaymentResultScreen extends StatelessWidget {
  final String status;
  final String message;

  const PaymentResultScreen({super.key, required this.status, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = status.toLowerCase() == 'success';

    return Scaffold(
      appBar: AppBar(title: const Text("Payment Result")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error,
                size: 80, color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(height: 20),
            Text(
              isSuccess ? "✅ Payment Successful" : "❌ Payment Failed",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.red,
              ),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
