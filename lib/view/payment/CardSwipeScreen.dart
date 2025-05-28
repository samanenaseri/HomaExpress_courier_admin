import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import 'payment_result_screen.dart';

class CardSwipeScreen extends StatefulWidget {
  final double amount;
  final PaymentService paymentService; // ✅ نوع اضافه شد

  const CardSwipeScreen({
    Key? key,
    required this.amount,
    required this.paymentService,
  }) : super(key: key);

  @override
  _CardSwipeScreenState createState() => _CardSwipeScreenState();
}

class _CardSwipeScreenState extends State<CardSwipeScreen> {
  @override
  void initState() {
    super.initState();

    widget.paymentService.onPaymentResult = (status, message) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentResultScreen(
            status: status,
            message: message,
          ),
        ),
      );
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.paymentService.startPayment(widget.amount);
    });
  }

  @override
  void dispose() {
    widget.paymentService.onPaymentResult = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Swipe Card')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Please swipe your card..."),
          ],
        ),
      ),
    );
  }
}
