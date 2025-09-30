abstract class PaymentResult {
  final bool success;
  final String? rrn;        // شماره مرجع
  final String? message;    // پیام خطا/موفقیت
  PaymentResult({required this.success, this.rrn, this.message});
}

class PaymentSuccess extends PaymentResult {
  PaymentSuccess({String? rrn, String? message})
      : super(success: true, rrn: rrn, message: message);
}

class PaymentFailure extends PaymentResult {
  PaymentFailure({String? message})
      : super(success: false, message: message);
}

abstract class PaymentGateway {
  /// amount به ریال (یا واحدی که SDK می‌خواهد)
  Future<PaymentResult> pay({
    required int amount,
    Map<String, dynamic>? extra,
  });
}
