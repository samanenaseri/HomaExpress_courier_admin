import 'dart:async';
import 'package:get/get.dart';
import '../services/payment_service.dart';

class PaymentController extends GetxController {
  final RxString orderNumber = ''.obs;
  final RxDouble amount = 0.0.obs;
  final RxBool isProcessing = false.obs;

  late final PaymentService _paymentService;

  // (اختیاری) تست: اگر می‌خواهی مبلغ تستی فورس شود
  static const bool kUseTestAmount = false;      // true کن تا تستی شود
  static const double kTestAmount  = 12345.0;

  // Fallback timer: اگر نتیجه‌ای نیامد، لودینگ را آزاد کن
  Timer? _fallbackTimer;
  static const Duration _fallbackTimeout = Duration(seconds: 60);

  @override
  void onInit() {
    super.onInit();

    // آرگومان‌ها
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    orderNumber.value = args['orderNumber']?.toString() ?? '';

    final raw = args['amount'];
    if (raw is num) {
    //  amount.value = raw.toDouble();
      amount.value =100.toDouble();
    } else {
      amount.value =100.toDouble();
      //amount.value = double.tryParse(raw?.toString() ?? '') ?? 0.0;
    }

    // if (kUseTestAmount) {
    //  // amount.value = kTestAmount;
    //   amount.value =100;
    // }

    // سرویس + لیسنر نتیجه
    _paymentService = PaymentService();
    _paymentService.setListener((String status, String message) {
      _clearFallback();

      if (isProcessing.value) {
        isProcessing.value = false;
      }

      Get.offAllNamed('/paymentResult', arguments: {
        'status': status,
        'message': message,
        'orderNumber': orderNumber.value,
        'amount': 100,
      });
    });
  }

  Future<void> startPayment() async {
   // if (isProcessing.value) return;

    final double finalAmount = amount.value;

    if (finalAmount <= 0) {
      Get.snackbar('خطا', 'مبلغ نامعتبر است');
      return;
    }

    isProcessing.value = true;

    // راه‌اندازی Fallback: اگر Callback نیامد، بعد از 60s آزاد کن
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(_fallbackTimeout, () {
      if (isProcessing.value) {
        isProcessing.value = false;
        Get.snackbar('انصراف/بی‌پاسخ', 'پرداخت لغو شد یا پاسخی از اپ بانکی دریافت نشد.');
      }
    });

    try {
      final ok = await _paymentService.startPayment(finalAmount, orderNumber: orderNumber.value);
      if (!ok) {
        _clearFallback();
        isProcessing.value = false;

        Get.offAllNamed('/paymentResult', arguments: {
          'status': 'ERROR',
          'message': 'Failed to invoke native payment',
          'orderNumber': orderNumber.value,
          'amount': finalAmount,
        });
      }
    } catch (e) {
      _clearFallback();
      isProcessing.value = false;
      Get.offAllNamed('/paymentResult', arguments: {
        'status': 'ERROR',
        'message': e.toString(),
        'orderNumber': orderNumber.value,
        'amount': finalAmount,
      });
    }
  }

  // اگر برگشتیم ولی callback نیومد، می‌تونی دستی صدا بزنی
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
