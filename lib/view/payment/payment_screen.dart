import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/payment_controller.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  late final PaymentController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // وقتی از اپ بانکی برمی‌گردیم، این فراخوانی می‌شود
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // اگر هنوز لودینگ روشن مانده و callback نیامده، آزادش کن
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && controller.isProcessing.value) {
          controller.resetProcessing();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('پرداخت')),
        body: Obx(() {
          final amount = controller.amount.value;
          final order = controller.orderNumber.value;
          final loading = controller.isProcessing.value;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('شماره سفارش: ${order.isEmpty ? "-" : order}'),
                const SizedBox(height: 8),
                Text('مبلغ: ${amount.toStringAsFixed(2)}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: loading ? null : controller.startPayment,
                  child: loading
                      ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('شروع پرداخت'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
