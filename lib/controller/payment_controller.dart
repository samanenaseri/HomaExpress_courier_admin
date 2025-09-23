// import 'dart:async';
// import 'package:get/get.dart';
// import '../services/payment_service.dart';
//
// class PaymentController extends GetxController {
//   final RxString orderNumber = ''.obs;
//   final RxInt amount = 0.obs;
//   final RxBool isProcessing = false.obs;
//
//   late final PaymentService _paymentService;
//
//   // (اختیاری) تست: اگر می‌خواهی مبلغ تستی فورس شود
//   static const bool kUseTestAmount = false;      // true کن تا تستی شود
//   static const double kTestAmount  = 12345.0;
//
//   // Fallback timer: اگر نتیجه‌ای نیامد، لودینگ را آزاد کن
//   Timer? _fallbackTimer;
//   static const Duration _fallbackTimeout = Duration(seconds: 60);
//
//   @override
//   void onInit() {
//     super.onInit();
//
//     // آرگومان‌ها
//     final args = Get.arguments as Map<String, dynamic>? ?? {};
//     orderNumber.value = args['orderNumber']?.toString() ?? '';
//
//     final raw = args['amount'];
//     if (raw is num) {
//     //  amount.value = raw.toDouble();
//       amount.value =10000;
//     } else {
//       amount.value =10000;
//       //amount.value = double.tryParse(raw?.toString() ?? '') ?? 0.0;
//     }
//
//     // if (kUseTestAmount) {
//     //  // amount.value = kTestAmount;
//     //   amount.value =100;
//     // }
//
//     // سرویس + لیسنر نتیجه
//     _paymentService = PaymentService();
//     _paymentService.setListener((String status, String message) {
//       _clearFallback();
//
//       if (isProcessing.value) {
//         isProcessing.value = false;
//       }
//
//       Get.offAllNamed('/paymentResult', arguments: {
//         'status': status,
//         'message': message,
//         'orderNumber': orderNumber.value,
//         'amount': 10000,
//       });
//     });
//   }
//
//   Future<void> startPayment() async {
//     if (isProcessing.value) return;
//
//     final int finalAmount = amount.value;
//
//     if (finalAmount <= 0) {
//       Get.snackbar('خطا', 'مبلغ نامعتبر است');
//       return;
//     }
//
//     isProcessing.value = true;
//
//     // راه‌اندازی Fallback: اگر Callback نیامد، بعد از 60s آزاد کن
//     _fallbackTimer?.cancel();
//     _fallbackTimer = Timer(_fallbackTimeout, () {
//       if (isProcessing.value) {
//         isProcessing.value = false;
//         Get.snackbar('انصراف/بی‌پاسخ', 'پرداخت لغو شد یا پاسخی از اپ بانکی دریافت نشد.');
//       }
//     });
//
//     try {
//       final ok = await _paymentService.startPayment(finalAmount, orderNumber: orderNumber.value);
//       if (!ok) {
//         _clearFallback();
//         isProcessing.value = false;
//
//         Get.offAllNamed('/paymentResult', arguments: {
//           'status': 'ERROR',
//           'message': 'Failed to invoke native payment',
//           'orderNumber': orderNumber.value,
//           'amount': finalAmount,
//         });
//       }
//     } catch (e) {
//       _clearFallback();
//       isProcessing.value = false;
//       Get.offAllNamed('/paymentResult', arguments: {
//         'status': 'ERROR',
//         'message': e.toString(),
//         'orderNumber': orderNumber.value,
//         'amount': finalAmount,
//       });
//     }
//   }
//
//   // اگر برگشتیم ولی callback نیومد، می‌تونی دستی صدا بزنی
//   void resetProcessing() {
//     _clearFallback();
//     isProcessing.value = false;
//   }
//
//   void _clearFallback() {
//     _fallbackTimer?.cancel();
//     _fallbackTimer = null;
//   }
//
//   @override
//   void onClose() {
//     _clearFallback();
//     _paymentService.removeListener();
//     super.onClose();
//   }
// }

import 'dart:async';
import 'package:get/get.dart';
import '../services/payment_service.dart';

class PaymentController extends GetxController {
  final RxString orderNumber = ''.obs;
  final RxInt amount = 0.obs; // مبلغ نمایشی (مثلاً تومان) به صورت عدد صحیح
  final RxBool isProcessing = false.obs;

  late final PaymentService _paymentService;

  // اگر نمایش توِمانه و درگاه "ریال" می‌خواد، true بگذار
  static const bool kAmountUnitIsToman = true;

  // برای تست سریع می‌تونی این رو true کنی و kTestAmount را تنظیم کنی
  static const bool kUseTestAmount = true;
  static const int kTestAmount = 1000; // مقدار تستی: عدد صحیح (مثلاً 1000 تومان)

  Timer? _fallbackTimer;
  static const Duration _fallbackTimeout = Duration(seconds: 60);

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    orderNumber.value = args['orderNumber']?.toString() ?? '';

    // parse amount از آرگومان اگر موجود باشه، وگرنه اگر kUseTestAmount فعال است مقدار تستی را بگذار
    final raw = args['amount'];
    int parsed = 0;
    if (raw is num) {
      parsed = raw.toInt();
    } else if (raw is String) {
      parsed = int.tryParse(raw) ?? 0;
    }

    if (parsed <= 0 && kUseTestAmount) {
      parsed = kTestAmount;
    }

    // اگر توی args هاردکدی گذاشتی، اینجا خوانده میشه؛ در غیر این صورت مقدار تستی میاد
    amount.value = parsed;

    _paymentService = PaymentService();

    // توجه: listener ما دقیقا دو پارامتر می‌پذیرد (status, message) مطابق پیاده‌سازی service
    _paymentService.setListener((String status, String message) {
      _clearFallback();

      if (isProcessing.value) {
        isProcessing.value = false;
      }

      // وقتی نتیجه از نیتیو آمد، به صفحه نتیجه برو
      Get.offAllNamed(
        '/paymentResult',
        arguments: {
          'status': status,
          'message': message,
          'orderNumber': orderNumber.value,
          'amount': amount.value, // مبلغ نمایشی (برای دیباگ/نمایش)
        },
      );
    });
  }

  Future<void> startPayment() async {
    // جلوگیری از دوبار کلیک/لانچ همزمان
    if (isProcessing.value) return;

    final int displayAmount = amount.value;
    if (displayAmount <= 0) {
      Get.snackbar('خطا', 'مبلغ نامعتبر است');
      return;
    }

    // تبدیل واحد نمایش (مثلاً تومان) به واحد مورد انتظار درگاه (اغلب ریال)
    final int amountForGateway = kAmountUnitIsToman ? displayAmount * 10 : displayAmount;

    // اعتبارسنجی مهم: orderNumber باید غیرخالی باشد
    if (orderNumber.value.trim().isEmpty) {
      Get.snackbar('خطا', 'orderNumber از سرور نرسیده یا خالی است.');
      return;
    }

    isProcessing.value = true;

    // Fallback safety
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(_fallbackTimeout, () {
      if (isProcessing.value) {
        isProcessing.value = false;
        Get.snackbar('انصراف/بی‌پاسخ', 'پرداخت بی‌پاسخ ماند یا لغو شد (timeout).');
      }
    });

    try {
      print('[PAY][Controller] invoking startPayment amountForGateway=$amountForGateway orderNo=${orderNumber.value}');

      final ok = await _paymentService.startPayment(
        amountForGateway,
        orderNumber: orderNumber.value,
      );

      if (!ok) {
        // اگر invoke اصلاً انجام نشده یا خطای immediate رخ داده، در همین صفحه پیام بده
        _clearFallback();
        isProcessing.value = false;
        Get.snackbar('خطا', 'فراخوانی اپ بانکی ناموفق بود (invoke نشد). لطفاً لاگ‌ها را چک کن.');
        return;
      }

      // اگر invoke موفق بوده: منتظر listener بمان (که بعدا نتیجه را خواهد فرستاد)
      // (هیچ ناوبری بیشتری اینجا انجام نخواهد شد)
    } catch (e) {
      _clearFallback();
      isProcessing.value = false;
      Get.offAllNamed('/paymentResult', arguments: {
        'status': 'ERROR',
        'message': e.toString(),
        'orderNumber': orderNumber.value,
        'amount': displayAmount,
      });
    }
  }

  void resetProcessing() {
    _clearFallback();
    isProcessing.value = false;
  }

  void _clearFallback() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  @override
  void onClose() {
    _clearFallback();
    _paymentService.removeListener();
    super.onClose();
  }
}
