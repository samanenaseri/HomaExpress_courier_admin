// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../utils/constants.dart';
//
// class PaymentResultScreen extends StatelessWidget {
//   const PaymentResultScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final args = Get.arguments ?? {};
//     final String status = args['status']?.toString() ?? 'unknown';
//     final String message = args['message']?.toString() ?? 'بدون پیام';
//
//     final bool isSuccess = status == 'success';
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(32.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
//                   size: 100,
//                   color: isSuccess ? Colors.green : Colors.red,
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   isSuccess ? 'پرداخت موفق بود' : 'پرداخت ناموفق بود',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: isSuccess ? Colors.green : Colors.red,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 32),
//                 ElevatedButton(
//                   onPressed: () => Get.back(), // یا مسیر دلخواه
//                   child: const Text('بازگشت'),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rawArgs = Get.arguments;
    final args = (rawArgs is Map)
        ? Map<String, dynamic>.from(rawArgs as Map)
        : <String, dynamic>{};

    final statusRaw = args['status']?.toString() ?? 'unknown';
    final status = statusRaw.toLowerCase();
    final bool isSuccess = status == 'success' || status == 'ok' || status == 'approved';

    final String message = args['message']?.toString() ?? 'بدون پیام';
    final String orderNumber = args['orderNumber']?.toString() ?? '-';

    final dynamic amountRaw = args['amount'];
    final double amount = (amountRaw is num)
        ? amountRaw.toDouble()
        : (double.tryParse(amountRaw?.toString() ?? '') ?? 0.0);

    final String? rrn = args['rrn']?.toString();
    final String? traceNo = args['traceNo']?.toString();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                    size: 96,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSuccess ? 'پرداخت موفق بود' : 'پرداخت ناموفق بود',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  Card(
                    elevation: 0,
                    color: AppColors.logoPurple.withOpacity(0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _kv('شماره سفارش', orderNumber),
                          _kv('مبلغ', amount > 0 ? amount.toStringAsFixed(0) : '-'),
                          if (rrn != null && rrn.isNotEmpty) _kv('RRN', rrn),
                          if (traceNo != null && traceNo.isNotEmpty) _kv('کد پیگیری', traceNo),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('بازگشت'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
