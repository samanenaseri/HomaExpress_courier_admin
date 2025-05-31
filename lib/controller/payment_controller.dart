import 'package:get/get.dart';
import '../services/payment_service.dart';

class PaymentController extends GetxController {
  final RxDouble amount = 0.0.obs;
  final RxString status = ''.obs;
  final RxString message = ''.obs;
  final RxBool isProcessing = false.obs;

  late PaymentService _paymentService;

  @override
  void onInit() {
    super.onInit();
    _paymentService = PaymentService();
    _paymentService.onPaymentResult = (String s, String m) {
      status.value = s;
      message.value = m;
      isProcessing.value = false;
      Get.offAllNamed('/paymentResult');
    };
  }

  void startPayment(double amt) {
    amount.value = amt;
    isProcessing.value = true;
    _paymentService.startPayment(amt);
  }

  void reset() {
    amount.value = 0.0;
    status.value = '';
    message.value = '';
    isProcessing.value = false;
  }
} 