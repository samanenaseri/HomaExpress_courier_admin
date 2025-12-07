import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/payment_service.dart';
import '../services/wallet_transition_service.dart';

class PaymentController extends GetxController {
  final RxString orderNumber = ''.obs;
  final RxDouble amount = 0.0.obs; // مبلغ بر حسب "ریال"
  final RxBool isProcessing = false.obs;

  final RxInt senderId = 0.obs;

  late final PaymentService _paymentService;
  late final WalletTransitionService _walletService;

  Timer? _fallbackTimer;
  static const Duration _fallbackTimeout = Duration(seconds: 60);

  String _token = '';

  final NumberFormat _fmt = NumberFormat('#,##0', 'en_US');

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    print("########################## y$args");
    orderNumber.value = args['orderNumber']?.toString() ?? '';

    senderId.value = args['customer_id'];
    final rawAmount = args['amount'];
    if (rawAmount is num) {
      amount.value = rawAmount.toDouble();
    } else {
      amount.value = double.tryParse(rawAmount?.toString() ?? '') ?? 0.0;
    }

    senderId.value = (args['customer_id'] ?? 0) as int;

    _paymentService = PaymentService();
    _walletService = WalletTransitionService();

    _paymentService.setListener(_onPaymentResult);

    _initPaymentController();
  }

  Future<void> _initPaymentController() async {
    await _loadToken();
    print('[PAY] Loaded token-------: $_token');
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    if (kDebugMode) {
      debugPrint('[PAY] Loaded token: ${_token.isNotEmpty ? 'OK' : 'EMPTY'}');
    }
  }

  String get formattedAmount {
    try {
      final v = amount.value.round();
      return _fmt.format(v); // "120,000" ریال
    } catch (e) {
      return amount.value.toString();
    }
  }

  Future<void> startPayment() async {
    if (isProcessing.value) return;

    final int displayAmount = amount.value.round(); // ریال

    if (displayAmount <= 0) {
      Get.snackbar('خطا', 'مبلغ نامعتبر است');
      return;
    }

    if (orderNumber.value
        .trim()
        .isEmpty) {
      Get.snackbar('خطا', 'orderNumber خالی است.');
      return;
    }

    final int amountForGateway = displayAmount; // ریال

    isProcessing.value = true;

    _clearFallback();
    _fallbackTimer = Timer(_fallbackTimeout, () {
      if (isProcessing.value) {
        isProcessing.value = false;
        Get.snackbar(
          'انصراف/بی‌پاسخ',
          'پرداخت بی‌پاسخ ماند یا لغو شد (timeout).',
        );
      }
    });

    try {
      if (kDebugMode) {
        debugPrint(
          '[PAY][Controller] attempting startPayment '
              'amountForGateway=$amountForGateway orderNo=${orderNumber.value}',
        );
      }
      print('========[PAY] USING TOKEN (for wallet later): $_token');

      final ok = await _paymentService.startPayment(
        amountForGateway,
        orderNumber: orderNumber.value,
      );

      if (!ok) {
        _clearFallback();
        isProcessing.value = false;
        Get.snackbar(
          'خطا',
          'فراخوانی اپ بانکی ناموفق بود (invoke failed). لاگ‌ها را چک کن.',
        );
      } else {
        if (kDebugMode) {
          debugPrint('[PAY][Controller] startPayment invoked successfully');
        }
      }
    } catch (e, st) {
      _clearFallback();
      isProcessing.value = false;
      debugPrint('[PAY][Controller] startPayment error: $e\n$st');
      Get.snackbar('خطا', 'خطا هنگام شروع پرداخت: ${e.toString()}');
    }
  }

  /// این متد نتیجه پرداخت را از Native می‌گیرد
  // void _onPaymentResult(Map<String, dynamic> result) async {
  //
  //   _clearFallback();
  //   //isProcessing.value = false;
  //
  //   print('================= PAYMENT RESULT =================');
  //   print('[PAY][Listener] RESULT MAP: $result');
  //   print('==================================================');
  //
  //   final raw = result['raw']?.toString() ??
  //       result['transaction']?.toString() ??
  //       result.toString();
  //
  //   final bankStatus = result['status']?.toString() ?? '';
  //   final bankMessage = result['message']?.toString();
  //
  //   print('[PAY][Listener] RAW STRING = $raw');
  //   print('[PAY][Listener] bankStatus = $bankStatus');
  //   print('[PAY][Listener] bankMessage = $bankMessage');
  //
  //   final bool looksSuccessful =
  //       bankStatus == '00' ||
  //           raw.contains('تراکنش موفق') ||
  //           raw.contains(',00,');
  //
  //   print('[PAY][Listener] looksSuccessful = $looksSuccessful');
  //
  //   String status = looksSuccessful ? 'success' : 'failed';
  //   String message;
  //
  //   if (!looksSuccessful) {
  //     // ❌ پرداخت ناموفق یا انصراف
  //     message = bankMessage != null && bankMessage.isNotEmpty
  //         ? bankMessage
  //         : 'پرداخت ناموفق بود.\n$raw';
  //
  //     Get.offNamed(
  //       '/paymentResult',
  //       arguments: {
  //         'status': status,
  //         'message': message,
  //         'orderNumber': orderNumber.value,
  //         'amount': amount.value,
  //         'rawResult': raw,
  //       },
  //     );
  //     return;
  //   }
  //
  //   // ✅ اینجا یعنی پرداخت موفق بوده
  //   message = 'پرداخت با موفقیت انجام شد.';
  //
  //   final numberTransition =
  //       _extractTrackingCodeFromRaw(raw) ?? orderNumber.value;
  //
  //   final paymentDate = _extractDateFromRaw(raw);
  //
  //   final int walletAmount = amount.value.round();
  //   final String priceStr = walletAmount.toString();
  //
  //   print('------------- CALLING WALLET SERVICE -------------');
  //   print('[PAY][Wallet] customerId = ${senderId.value}');
  //   print('[PAY][Wallet] numberTransition = $numberTransition');
  //   print('[PAY][Wallet] paymentDate = $paymentDate');
  //   print('[PAY][Wallet] price = $priceStr');
  //   print('[PAY][Wallet] token empty? ${_token.isEmpty}');
  //   print('[PAY][Wallet] token before wallet call: $_token');
  //   print('--------------------------------------------------');
  //
  //   try {
  //     final ok = await _walletService.createWalletTransition(
  //       customerId: senderId.value,
  //       numberTransition: numberTransition,
  //       paymentDate: paymentDate,
  //       price: priceStr,
  //       token: _token,
  //     );
  //
  //     print('[PAY][Wallet] service returned ok = $ok');
  //
  //     if (!ok) {
  //       message +=
  //       '\n پرداخت انجام شد ';
  //       //Get.snackbar('هشدار', message);
  //     }
  //   } catch (e, st) {
  //     print('[PAY][Wallet] error: $e\n$st');
  //     message += '\n(خطا در ارتباط با سرور برای ثبت پرداخت)';
  //     Get.snackbar('خطا', message);
  //   }
  //
  //   Get.offNamed(
  //     '/paymentResult',
  //     arguments: {
  //       'status': status,
  //       'message': message,
  //       'orderNumber': orderNumber.value,
  //       'amount': amount.value,
  //       'rawResult': raw,
  //     },
  //   );
  // }
//for better design
  void _onPaymentResult(Map<String, dynamic> result) async {
    print('🔥🔥🔥 ENTERED _onPaymentResult 🔥🔥🔥');
    print('XC_DEBUG 5) ENTERED _onPaymentResult with result = $result');

    _clearFallback();
    // ❌ دیگه isProcessing = false نمی‌ذاریم اینجا

    print('================= PAYMENT RESULT =================');
    print('[PAY][Listener] RESULT MAP: $result');
    print('==================================================');

    final raw = result['raw']?.toString() ??
        result['transaction']?.toString() ??
        result.toString();

    final bankStatus = result['status']?.toString() ?? '';
    final bankMessage = result['message']?.toString();

    print('[PAY][Listener] RAW STRING = $raw');
    print('[PAY][Listener] bankStatus = $bankStatus');
    print('[PAY][Listener] bankMessage = $bankMessage');

    final bool looksSuccessful =
        bankStatus == '00' ||
            raw.contains('تراکنش موفق') ||
            raw.contains(',00,');

    print('[PAY][Listener] looksSuccessful = $looksSuccessful');

    String status = looksSuccessful ? 'success' : 'failed';
    String message;

    // ❌ پرداخت ناموفق یا انصراف → فقط صفحه نتیجه‌ی خطا، بدون Snackbar اضافه
    if (!looksSuccessful) {
      message = bankMessage != null && bankMessage.isNotEmpty
          ? bankMessage
          : 'پرداخت ناموفق بود.\n$raw';

      Get.offNamed(
        '/paymentResult',
        arguments: {
          'status': status,
          'message': message,
          'orderNumber': orderNumber.value,
          'amount': amount.value,
          'rawResult': raw,
        },
      );
      return;
    }

    // ✅ اینجا یعنی پرداخت موفق بوده
    message = 'پرداخت با موفقیت انجام شد.';

    final numberTransition =
        _extractTrackingCodeFromRaw(raw) ?? orderNumber.value;

    final paymentDate = _extractDateFromRaw(raw);

    final int walletAmount = amount.value.round();
    final String priceStr = walletAmount.toString();

    print('------------- CALLING WALLET SERVICE -------------');
    print('[PAY][Wallet] customerId = ${senderId.value}');
    print('[PAY][Wallet] numberTransition = $numberTransition');
    print('[PAY][Wallet] paymentDate = $paymentDate');
    print('[PAY][Wallet] price = $priceStr');
    print('[PAY][Wallet] token empty? ${_token.isEmpty}');
    print('[PAY][Wallet] token before wallet call: $_token');
    print('--------------------------------------------------');

    try {
      final ok = await _walletService.createWalletTransition(
        customerId: senderId.value,
        numberTransition: numberTransition,
        paymentDate: paymentDate,
        price: priceStr,
        token: _token,
      );

      print('[PAY][Wallet] service returned ok = $ok');
      // ❗ دیگه message رو دستکاری نمی‌کنیم، Snackbar هم نمی‌زنیم
    } catch (e, st) {
      print('[PAY][Wallet] error: $e\n$st');
      // بازم Snackbar نداریم؛ فقط لاگ می‌گیریم که UI تمیز بماند
    }

    // در هر حالت (wallet موفق / ناموفق)، فقط به صفحه نتیجه می‌رویم
    Get.offNamed(
      '/paymentResult',
      arguments: {
        'status': status,
        'message': message, // ✅ دیگه "ثبت در کیف پول ناموفق بود" بهش نچسبیده
        'orderNumber': orderNumber.value,
        'amount': amount.value,
        'rawResult': raw,
      },
    );
  }

  String? _extractTrackingCodeFromRaw(String raw) {
    final reg = RegExp(r'\b\d{6,12}\b');
    final match = reg.firstMatch(raw);
    return match?.group(0);
  }

  DateTime _extractDateFromRaw(String raw) {
    final regJalali = RegExp(r'14\d{2}/\d{2}/\d{2}');
    final match = regJalali.firstMatch(raw);

    if (match != null) {
      try {
        final parts = match.group(0)!.split('/');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        final jalali = Jalali(year, month, day);
        final gregorian = jalali.toGregorian();

        return DateTime(gregorian.year, gregorian.month, gregorian.day);
      } catch (e) {
        debugPrint('[PAY][DateParse] Error parsing Jalali date: $e');
      }
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
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