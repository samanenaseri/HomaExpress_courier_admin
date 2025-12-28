import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homaexpress_courier_admin/utils/constants.dart';
import '../../controller/payment_controller.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}
class _PaymentScreenState extends State<PaymentScreen> {
  late final PaymentController controller;

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PaymentController>()) {
      Get.delete<PaymentController>(force: true);
    }
    controller = Get.put(PaymentController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final loading = controller.isProcessing.value;

        if (loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('پرداخت')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final amount = controller.amount.value;
        final order = controller.orderNumber.value;

        return Scaffold(
          appBar: AppBar(title: const Text('پرداخت')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('شماره سفارش: ${order.isEmpty ? "-" : order}'),
                const SizedBox(height: 8),
                Text('مبلغ: ${amount.toStringAsFixed(0)} ریال'),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.startPayment,
                    child: const Text('شروع پرداخت'),
                  ),
                ),
                const SizedBox(height: 12),

              ],
            ),
          ),
        );
      }),
    );
  }
}

