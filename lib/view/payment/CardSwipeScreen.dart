// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import '../../services/payment_service.dart';
// // import '../../utils/constants.dart';
// //
// // class CardSwipeScreen extends StatefulWidget {
// //   final double amount;
// //
// //   const CardSwipeScreen({
// //     Key? key,
// //     required this.amount,
// //   }) : super(key: key);
// //
// //   @override
// //   _CardSwipeScreenState createState() => _CardSwipeScreenState();
// // }
// //
// // class _CardSwipeScreenState extends State<CardSwipeScreen> with SingleTickerProviderStateMixin {
// //   late AnimationController _controller;
// //   late Animation<double> _animation;
// //   final PaymentService _paymentService = PaymentService();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(seconds: 1),
// //     )..repeat(reverse: true);
// //     _animation = Tween<double>(begin: 0, end: 30).animate(
// //       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
// //     );
// //
// //     _paymentService.setListener((status, message) {
// //       Get.offAllNamed('/paymentResult', arguments: {
// //         'status': status,
// //         'message': message,
// //       });
// //     });
// //
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _paymentService.startPayment(widget.amount);
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _paymentService.removeListener();
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             const SizedBox(height: 32),
// //             Text(
// //               'لطفا کارت خود را بکشید',
// //               style: TextStyle(
// //                 fontSize: 26,
// //                 fontWeight: FontWeight.bold,
// //                 color: AppColors.logoPurple,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //             Expanded(
// //               child: Center(
// //                 child: AnimatedBuilder(
// //                   animation: _animation,
// //                   builder: (context, child) {
// //                     return Stack(
// //                       alignment: Alignment.center,
// //                       children: [
// //                         Icon(
// //                           Icons.phone_android,
// //                           size: 120,
// //                           color: AppColors.logoPurple.withOpacity(0.3),
// //                         ),
// //                         Positioned(
// //                           top: 60 - _animation.value,
// //                           child: Icon(
// //                             Icons.credit_card,
// //                             size: 70,
// //                             color: AppColors.logoPurple,
// //                           ),
// //                         ),
// //                       ],
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
// //               child: SizedBox(
// //                 width: double.infinity,
// //                 height: 56,
// //                 child: ElevatedButton(
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: AppColors.mainPurple,
// //                     foregroundColor: Colors.white,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                   onPressed: () => Get.back(),
// //                   child: const Text(
// //                     'انصراف از خرید',
// //                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../services/payment_service.dart';
// import '../../utils/constants.dart';
//
// class CardSwipeScreen extends StatefulWidget {
//   // اگر از constructor استفاده نمی‌کنی، می‌توانی این را هم حذف کنی
//   final double? amount;
//
//   const CardSwipeScreen({Key? key, this.amount}) : super(key: key);
//
//   @override
//   State<CardSwipeScreen> createState() => _CardSwipeScreenState();
// }
//
// class _CardSwipeScreenState extends State<CardSwipeScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   final PaymentService _paymentService = PaymentService();
//
//   // داده‌های تراکنش
//   String orderNumber = '';
//   double amount = 0.0;
//
//   // جلوگیری از ناوبری چندباره
//   bool _navigated = false;
//
//   static const String resultRoute = '/paymentResult'; // یکسان با بقیه جاها
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
//       ..repeat(reverse: true);
//     _animation = Tween<double>(begin: 0, end: 30)
//         .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//
//     // خواندن امن آرگومان‌ها
//     final args = Get.arguments as Map<String, dynamic>? ?? {};
//     orderNumber = args['orderNumber']?.toString() ?? '';
//     final raw = args.containsKey('amount') ? args['amount'] : widget.amount;
//     if (raw is num) {
//       amount = raw.toDouble();
//     } else {
//       amount = double.tryParse(raw?.toString() ?? '') ?? 0.0;
//     }
//
//     // Listener نتیجه
//     _paymentService.setListener((status, message) {
//       if (_navigated) return;
//       _navigated = true;
//       Get.offAllNamed(resultRoute, arguments: {
//         'status': status,
//         'message': message,
//         'orderNumber': orderNumber,
//         'amount': amount,
//       });
//     });
//
//     // شروع پرداخت بعد از اولین فریم
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final ok = await _paymentService.startPayment(amount, orderNumber: orderNumber);
//       if (!ok && !_navigated) {
//         _navigated = true;
//         Get.offAllNamed(resultRoute, arguments: {
//           'status': 'ERROR',
//           'message': 'Failed to invoke native payment',
//           'orderNumber': orderNumber,
//           'amount': amount,
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _paymentService.removeListener();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _cancelPayment() async {
//     // اگر SDK متد cancel دارد، اینجا صدا بزن
//     if (!_navigated && mounted) {
//       _navigated = true;
//       Get.back();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const SizedBox(height: 32),
//               Text(
//                 'لطفا کارت خود را بکشید',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.logoPurple,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               Expanded(
//                 child: Center(
//                   child: AnimatedBuilder(
//                     animation: _animation,
//                     builder: (context, child) {
//                       return Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Icon(
//                             Icons.phone_android,
//                             size: 120,
//                             color: AppColors.logoPurple.withOpacity(0.3),
//                           ),
//                           Positioned(
//                             top: 60 - _animation.value,
//                             child: Icon(
//                               Icons.credit_card,
//                               size: 70,
//                               color: AppColors.logoPurple,
//                             ),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.mainPurple,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: _cancelPayment,
//                     child: const Text(
//                       'انصراف از خرید',
//                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
