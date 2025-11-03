// lib/controllers/payment_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/payment_service.dart';

/// اگر مبلغ UI بر حسب تومان است و باید ریال بفرستی -> true
const bool kAmountUnitIsToman = true;

class PaymentController extends GetxController {
  final RxString orderNumber = ''.obs;
  final RxDouble amount = 0.0.obs;        // مبلغ به صورت "نمایشی" (مثلاً تومان)
  final RxBool isProcessing = false.obs;

  late final PaymentService _paymentService;

  Timer? _fallbackTimer;
  static const Duration _fallbackTimeout = Duration(seconds: 60);

  // Formatter برای جداکننده‌ی هزارگان
  final NumberFormat _fmt = NumberFormat('#,##0', 'en_US');

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    orderNumber.value = args['orderNumber']?.toString() ?? '';

    final raw = args['amount'];
    if (raw is num) {
      amount.value = raw.toDouble();
    } else {
      amount.value = double.tryParse(raw?.toString() ?? '') ?? 0.0;
    }

    _paymentService = PaymentService();
    _paymentService.setListener((Map<dynamic, dynamic> result) {
      // انتظار داریم result حداقل شامل status و message باشد
      _clearFallback();
      isProcessing.value = false;

      final status = result['status']?.toString() ?? 'unknown';
      final message = result['message']?.toString() ?? '';

      if (kDebugMode) debugPrint('[PAY][Listener] status=$status message=$message');

      Get.offAllNamed('/paymentResult', arguments: {
        'status': status,
        'message': message,
        'orderNumber': orderNumber.value,
        'amount': amount.value,
      });
    });
  }

  /// رشته فرمت‌شده برای نمایش مبلغ (مثلاً "12,345")
  String get formattedAmount {
    try {
      final v = amount.value.round();
      return _fmt.format(v);
    } catch (e) {
      return amount.value.toString();
    }
  }

  Future<void> startPayment() async {
    if (isProcessing.value) return;

    final int displayAmount = amount.value.round();

    if (displayAmount <= 0) {
      Get.snackbar('خطا', 'مبلغ نامعتبر است');
      return;
    }

    if (orderNumber.value.trim().isEmpty) {
      Get.snackbar('خطا', 'orderNumber خالی است.');
      return;
    }

    final int amountForGateway = kAmountUnitIsToman ? displayAmount * 10 : displayAmount;

    isProcessing.value = true;

    _clearFallback();
    _fallbackTimer = Timer(_fallbackTimeout, () {
      if (isProcessing.value) {
        isProcessing.value = false;
        Get.snackbar('انصراف/بی‌پاسخ', 'پرداخت بی‌پاسخ ماند یا لغو شد (timeout).');
      }
    });

    try {
      if (kDebugMode) {
        debugPrint('[PAY][Controller] attempting startPayment amountForGateway=$amountForGateway orderNo=${orderNumber.value}');
      }

      // ابتدا چک کنیم آیا اپ پرداخت نصب هست (فراخوانی isPaymentAppInstalled)
      final bool isInstalled = await _paymentService.isPaymentAppInstalled();
      if (!isInstalled) {
        _clearFallback();
        isProcessing.value = false;
        Get.snackbar('خطا', 'اپ پرداخت نصب نیست. لطفاً اپ مورد نیاز را نصب کنید.');
        return;
      }

      final ok = await _paymentService.startPayment(
        amountForGateway,
        orderNumber: orderNumber.value,
        test: false,
        launchRealAppInTest: false, // مسیر واقعی
      );

      if (!ok) {
        _clearFallback();
        isProcessing.value = false;
        Get.snackbar('خطا', 'فراخوانی اپ بانکی ناموفق بود (invoke failed). لاگ‌ها را چک کن.');
      } else {
        if (kDebugMode) debugPrint('[PAY][Controller] startPayment invoked successfully');
      }
    } catch (e, st) {
      _clearFallback();
      isProcessing.value = false;
      debugPrint('[PAY][Controller] startPayment error: $e\n$st');
      Get.snackbar('خطا', 'خطا هنگام شروع پرداخت: ${e.toString()}');
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
