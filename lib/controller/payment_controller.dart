import 'dart:async';
import 'package:get/get.dart';
import '../services/payment_service.dart';

class PaymentController extends GetxController {
  /// شماره سفارش که از سرور می‌آید
  final RxString orderNumber = ''.obs;

  /// مبلغ نمایشی (تومان) به صورت عدد صحیح
  final RxInt amount = 0.obs;

  /// وضعیت در حال پردازش (برای لودینگ و جلوگیری از دوبار کلیک)
  final RxBool isProcessing = false.obs;

  late final PaymentService _paymentService;

  /// اگر واحد نمایش "تومان" و اپ مقصد "ریال" می‌خواهد، true بماند
  static const bool kAmountUnitIsToman = true;

  /// حالت تست فعال است؟
  static const bool kUseTestAmount  = true;

  /// اگر true باشد، همیشه مبلغ تستی جایگزین می‌شود حتی اگر از Route مبلغ واقعی آمده باشد
  static const bool kForceTestAmount = true;

  /// مبلغ تستی (تومان)
  static const int  kTestAmount = 1000;

  /// Timeout بازگشت نتیجه از اپ پرداخت
  static const Duration _fallbackTimeout = Duration(seconds: 60);
  Timer? _fallbackTimer;

  bool _isSuccessStatus(String s) {
    final v = s.trim().toLowerCase();
    return v == 'success' || v == 'successful' || v == 'ok' || v == 'approved' || v == '0' || v == '00' || v == 'true';
  }

  @override
  void onInit() {
    super.onInit();

    // خواندن ورودی‌ها
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    orderNumber.value = args['orderNumber']?.toString() ?? '';

    // پارس مبلغ ورودی
    final raw = args['amount'];
    int parsed = 0;
    if (raw is num) {
      parsed = raw.toInt();
    } else if (raw is String) {
      parsed = int.tryParse(raw) ?? 0;
    }

    // اعمال سیاست تست
    if (kForceTestAmount && kUseTestAmount) {
      parsed = kTestAmount;
    } else if (parsed <= 0 && kUseTestAmount) {
      parsed = kTestAmount;
    }
    amount.value = parsed;

    // سرویس و لیسنر نتیجه
    _paymentService = PaymentService();
    _paymentService.setListener((String status, String message) {
      _clearFallback();
      if (isProcessing.value) isProcessing.value = false;

      final normalized = _isSuccessStatus(status) ? 'SUCCESS' : 'FAILED';

      Get.offAllNamed('/paymentResult', arguments: {
        'status': normalized,
        'message': message,
        'orderNumber': orderNumber.value,
        'amount': amount.value,
      });
    });
  }

  /// شروع پرداخت
  Future<void> startPayment() async {
    if (isProcessing.value) return;

    final int displayAmount = (kForceTestAmount && kUseTestAmount)
        ? kTestAmount
        : amount.value;

    if (displayAmount <= 0) {
      Get.snackbar('خطا', 'مبلغ نامعتبر است');
      return;
    }

    // تبدیل تومان → ریال در صورت نیاز
    final int amountForGateway = kAmountUnitIsToman ? displayAmount * 10 : displayAmount;

    if (orderNumber.value.trim().isEmpty) {
      Get.snackbar('خطا', 'orderNumber از سرور نرسیده یا خالی است.');
      return;
    }

    isProcessing.value = true;

    // راه‌اندازی fallback
    _fallbackTimer?.cancel();
    _fallbackTimer = Timer(_fallbackTimeout, () {
      if (isProcessing.value) {
        isProcessing.value = false;
        Get.snackbar('انصراف/بی‌پاسخ', 'پرداخت بی‌پاسخ ماند یا لغو شد (timeout).');
      }
    });

    try {
      print('[PAY][Controller] startPayment amountForGateway=$amountForGateway orderNo=${orderNumber.value}');

      final ok = await _paymentService.startPayment(
        amountForGateway,
        orderNumber: orderNumber.value,
        test: true, // ← در فاز تست روشن باشد
      );

      if (!ok) {
        _clearFallback();
        isProcessing.value = false;
        Get.snackbar('خطا', 'فراخوانی اپ بانکی ناموفق بود (invoke failed). لاگ‌ها را چک کن.');
      }
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

  /// وقتی از اپ بانکی برگشتیم و هنوز لودینگ روشن مانده بود
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
