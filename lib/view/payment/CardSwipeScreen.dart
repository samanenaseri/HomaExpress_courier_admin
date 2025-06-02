import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/payment_service.dart';
import '../../utils/constants.dart';

class CardSwipeScreen extends StatefulWidget {
  final double amount;
  final PaymentService paymentService;

  const CardSwipeScreen({
    Key? key,
    required this.amount,
    required this.paymentService,
  }) : super(key: key);

  @override
  _CardSwipeScreenState createState() => _CardSwipeScreenState();
}

class _CardSwipeScreenState extends State<CardSwipeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    widget.paymentService.onPaymentResult = (status, message) {
      Get.offAllNamed('/paymentResult', arguments: {
        'status': status,
        'message': message,
      });
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.paymentService.startPayment(widget.amount);
    });
  }

  @override
  void dispose() {
    widget.paymentService.onPaymentResult = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 32),
            Text(
              'لطفا کارت خود را بکشید',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.logoPurple,
              ),
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // POS device
                        Icon(
                          Icons.phone_android,
                          size: 120,
                          color: AppColors.logoPurple.withOpacity(0.3),
                        ),
                        // Animated card
                        Positioned(
                          top: 60 - _animation.value,
                          child: Icon(
                            Icons.credit_card,
                            size: 70,
                            color: AppColors.logoPurple,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text(
                    'انصراف از خرید',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
