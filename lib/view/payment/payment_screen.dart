import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homaexpress_courier_admin/services/payment_service.dart';
import 'package:homaexpress_courier_admin/utils/custom_appbar.dart';
import 'package:homaexpress_courier_admin/view/payment/CardSwipeScreen.dart';
import '../../controller/payment_controller.dart';


class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});

  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String orderNumber = args['orderNumber']?.toString() ?? '';
    final double amount = (args['amount'] is double)
        ? args['amount']
        : double.tryParse(args['amount']?.toString() ?? '') ?? 0.0;
    controller.reset();

    return Scaffold(
     appBar: CustomAppBar(
      title: 'پرداخت سفارش',
    ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 64, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  Text('شماره سفارش: $orderNumber',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('مبلغ قابل پرداخت:',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                  Text('${amount.toStringAsFixed(0)} تومان',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 32),
                  controller.isProcessing.value
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.credit_card),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Get.to(() => CardSwipeScreen(amount: amount, paymentService: PaymentService()));
                            },
                            label: const Text('پرداخت'),
                          ),
                        ),
                  const SizedBox(height: 24),
                  if (controller.status.value.isNotEmpty)
                    Column(
                      children: [
                        Icon(
                          controller.status.value == 'success' ? Icons.check_circle : Icons.error,
                          color: controller.status.value == 'success' ? Colors.green : Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.status.value == 'success' ? 'پرداخت موفق' : 'پرداخت ناموفق',
                          style: TextStyle(
                            color: controller.status.value == 'success' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(controller.message.value, textAlign: TextAlign.center),
                      ],
                    ),
                ],
              )),
        ),
      ),
    );
  }
}
