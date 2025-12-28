// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:homaexpress_courier_admin/view/pickup_view.dart';
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
//                   onPressed: () => Get.offAllNamed('/pickups'), // یا مسیر دلخواه
//                   child: const Text('بازگشت به لیست مرسوله‌ها'),
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
import 'package:flutter/foundation.dart'; // kDebugMode

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final String status = args['status']?.toString() ?? 'unknown';

    String message = args['message']?.toString() ?? '';
    final String? rawResult = args['rawResult']?.toString();

    final bool isSuccess = status == 'success';

    // null را از UI حذف کن
    if (message.trim().isEmpty || message.toLowerCase() == 'null') {
      message = isSuccess ? 'پرداخت با موفقیت انجام شد.' : 'پرداخت لغو شد یا ناموفق بود.';
    }

    // فقط دیباگ: توی کنسول
    if (kDebugMode && rawResult != null && rawResult.isNotEmpty) {
      // debugPrint('=== PAYMENT RAW RESULT ===');
      // debugPrint(rawResult);
      // debugPrint('==========================');
    }

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
                  onPressed: () => Get.offAllNamed('/pickups'),
                  child: const Text('بازگشت به لیست مرسوله‌ها'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
