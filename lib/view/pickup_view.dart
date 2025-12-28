import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homaexpress_courier_admin/services/wallet_transition_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/pickup_controller.dart';
import '../utils/constants.dart';
import '../utils/custom_appbar.dart';
import '../utils/drawer_widget.dart';
import 'package:intl/intl.dart';
import '../services/printer_service.dart';

class PickupView extends StatelessWidget {
  final PickupController controller = Get.put(PickupController());

  Future<String?> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,

      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop) {
          Get.snackbar('توجه', 'در این صفحه امکان بازگشت وجود ندارد');
        }
      }, //When false, blocks the current route from being popped.
      child: Scaffold(
        drawer: CustomDrawer(),
        appBar: CustomAppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                Get.offAllNamed('/dashboard');

                // یا اگر می‌خوای فقط یه صفحه قبلی تو اپ خودت باشه:
                // Get.back();
              },
            ),
          ],
          title: 'Pickup List',
          backgroundColor: AppColors.logoGold,
          textColor: Colors.white,
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.pickups.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchPickups(refresh: true),
            child: ListView.builder(
              itemCount:
                  controller.pickups.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.pickups.length) {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final pickup = controller.pickups[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.logoPurple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${pickup.orderNumber}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          // height: 50.0,
                          // width: 35,
                          child: ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _bottomSheetItems(
                                        context: context,
                                        icon: Icons.photo,
                                        text: 'آپلود کارت ملی',
                                        onTap: () async {
                                          Get.back(); // به‌جای Navigator
                                          Future.microtask(() => controller.uploadAttachmentForOrder(pickup.id));
                                        },

                                      ),
                                      _bottomSheetItems(
                                        context: context,
                                        icon: Icons.photo,
                                        text: 'پرداخت',
                                        onTap: () async {
                                          final wallet =
                                              WalletTransitionService();
                                          final token =
                                              await _loadToken(); // همون تو SharedPreferences
                                          final customerId = pickup.senderId;
                                          final orderNumber = pickup.id;
                                          // print(
                                          //   '=====order_id is $orderNumber=======',
                                          // );
                                          // print('=====token is $token=======');

                                          final check = await wallet
                                              .checkPaymentStatus(
                                                customerId: customerId,
                                                orderId: pickup.id,
                                                token: token,
                                              );

                                          if (check != null &&
                                              check['status'] == 'paid') {
                                            final nt =
                                                check['numberTransition']
                                                    ?.toString();

                                            Get.snackbar(
                                              'تراکنش تکراری',
                                              nt != null && nt.isNotEmpty
                                                  ? 'این سفارش قبلاً پرداخت شده.\nکد پیگیری: $nt'
                                                  : 'این سفارش قبلاً پرداخت شده.',
                                              snackPosition: SnackPosition.TOP,

                                              backgroundColor:
                                                  AppColors.logoPurple,
                                              // 👈 بنفش تیره، بدون opacity
                                              colorText: Colors.white,

                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 16,
                                                  ),

                                              borderRadius: 16,
                                              isDismissible: true,
                                              dismissDirection:
                                                  DismissDirection.horizontal,

                                              duration: const Duration(
                                                seconds: 6,
                                              ),
                                              // 👈 زمان بیشتر
                                              animationDuration: const Duration(
                                                milliseconds: 400,
                                              ),

                                              icon: const Icon(
                                                Icons.info_outline,
                                                color: Colors.white,
                                                size: 28,
                                              ),

                                              titleText: const Text(
                                                'تراکنش تکراری',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),

                                              messageText: Text(
                                                nt != null && nt.isNotEmpty
                                                    ? 'این سفارش قبلاً پرداخت شده\nکد پیگیری: $nt'
                                                    : 'این سفارش قبلاً پرداخت شده.',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  height: 1.4,
                                                ),
                                              ),
                                            );

                                            return; // ❌ اصلاً نرو صفحه پرداخت
                                          }

                                          // ✅ فقط اگر پرداخت نشده بود
                                          Get.toNamed(
                                            '/payment',
                                            arguments: {
                                              'id': pickup.id,
                                              'orderNumber': pickup.orderNumber,
                                              'amount': pickup.totalPrice,
                                              'customer_id': pickup.senderId,
                                            },
                                          );
                                        },
                                      ),
                                      _bottomSheetItems(
                                        context: context,
                                        icon: Icons.photo,
                                        text: 'چاپ رسید',
                                        onTap: () async {
                                          final pickupOrder = pickup;
                                          final sender = pickupOrder.sender;
                                          final receiver = pickupOrder.receiver;
                                          final senderAddress =
                                              pickupOrder.senderAddress;
                                          final receiverAddress =
                                              pickupOrder.receiverAddress;
                                          final originCity =
                                              senderAddress?.city;
                                          final destCity =
                                              receiverAddress?.city;
                                          final originCountry =
                                              originCity?.country;
                                          final destCountry = destCity?.country;
                                          List<String> receiptLines = [
                                            pickupOrder.orderNumber,
                                            'هما اکسپرس',
                                            'Homa Express',
                                            'شعبه تهران',
                                            '---------------------------',
                                            'مشخصات فرستنده',
                                            'کد ملی: \t${sender?.phone ?? "-"}',
                                            'فرستنده: ${senderAddress?.name ?? "-"}',
                                            'مبدا: ${originCountry?.faName ?? "-"} ${originCity?.faName ?? "-"}',
                                            'آدرس: ${senderAddress?.address ?? "-"}',
                                            '---------------------------',
                                            'مشخصات گیرنده',
                                            'گیرنده: ${receiverAddress?.name ?? "-"}',
                                            'کد ملی: ${receiver?.phone ?? "-"}',
                                            'مقصد: ${destCountry?.faName ?? "-"} ${destCity?.faName ?? "-"}',
                                            'آدرس: ${receiverAddress?.address ?? "-"}',
                                            '---------------------------',
                                            'مشخصات مرسوله',
                                            'وزن: ${pickupOrder.totalCosts} کیلوگرم',
                                            'ارزش اظهار شده: ${pickupOrder.totalPrice}',
                                            'تاریخ قبول: ${pickupOrder.createdAt.year}-${pickupOrder.createdAt.month}-${pickupOrder.createdAt.day}',
                                            '---------------------------',
                                            'مرکز تماس: ۸۹۴۴',
                                            'www.homaexpressco.com',
                                          ];
                                          // Add extra empty lines to ensure the last lines are printed
                                          receiptLines.addAll([
                                            '',
                                            '',
                                            '',
                                            '',
                                            '',
                                          ]);
                                          final printerService =
                                              PrinterService();
                                          final success = await printerService
                                              .printReceipt(receiptLines);
                                          if (success) {
                                            Get.snackbar(
                                              'چاپ رسید',
                                              'رسید با موفقیت چاپ شد',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );
                                          } else {
                                            Get.snackbar(
                                              'خطا',
                                              'چاپ رسید ناموفق بود',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(30, 35),
                              backgroundColor: AppColors.logoPurple.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AppColors.logoPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(
                                  width: 1.0,
                                  color: AppColors.mainPurple,
                                ),
                              ),
                              elevation: 0,
                            ),

                            child: Icon(Icons.settings),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pickup.senderAddress != null) ...[
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          color: AppColors.logoPurple,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'اطلاعات فرستنده',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 24),
                                    _buildInfoRow(
                                      'نام',
                                      pickup.senderAddress!.name,
                                    ),
                                    _buildInfoRow(
                                      'موبایل',
                                      pickup.senderAddress!.mobile,
                                    ),
                                    _buildInfoRow(
                                      'آدرس',
                                      pickup.senderAddress!.address,
                                    ),
                                    if (pickup.senderAddress!.city != null)
                                      _buildInfoRow(
                                        'شهر',
                                        pickup.senderAddress!.city!.faName,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                            if (pickup.receiverAddress != null) ...[
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          color: AppColors.logoPurple,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'اطلاعات گیرنده',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(height: 24),
                                    _buildInfoRow(
                                      'نام',
                                      pickup.receiverAddress!.name,
                                    ),
                                    _buildInfoRow(
                                      'موبایل',
                                      pickup.receiverAddress!.mobile,
                                    ),
                                    _buildInfoRow(
                                      'آدرس',
                                      pickup.receiverAddress!.address,
                                    ),
                                    if (pickup.receiverAddress!.city != null)
                                      _buildInfoRow(
                                        'شهر',
                                        pickup.receiverAddress!.city!.faName,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: AppColors.logoPurple,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'اطلاعات سفارش',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 24),
                                  _buildInfoRow(
                                    'شماره سفارش',
                                    pickup.orderNumber,
                                  ),
                                  _buildInfoRow('نوع سفارش', pickup.orderType),
                                  _buildInfoRow(
                                    'قیمت کل',
                                    '${pickup.totalPrice} ریال ',
                                  ),
                                  _buildInfoRow(
                                    'مبلغ COD',
                                    '${pickup.codAmount} ریال ',
                                  ),
                                  if (pickup.courierName != null)
                                    _buildInfoRow(
                                      'نام پیک',
                                      pickup.courierName!,
                                    ),
                                  if (pickup.numberBillOfLading != null)
                                    _buildInfoRow(
                                      'شماره بارنامه',
                                      pickup.numberBillOfLading!,
                                    ),
                                  _buildInfoRow(
                                    'تاریخ ایجاد',
                                    DateFormat(
                                      'yyyy/MM/dd HH:mm',
                                    ).format(pickup.createdAt),
                                  ),
                                  _buildInfoRow(
                                    'آخرین بروزرسانی',
                                    DateFormat(
                                      'yyyy/MM/dd HH:mm',
                                    ).format(pickup.updatedAt),
                                  ),
                                ],
                              ),
                            ),
                            if (pickup.status == 'pending')
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton(
                                  onPressed:
                                      () =>
                                          controller.completePickup(pickup.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('تکمیل سفارش'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _bottomSheetItems({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool closeSheetOnTap = true,
  }) => ListTile(
    leading: Icon(icon, color: AppColors.logoGold),
    title: Text(text, style: AppTextStyles.bottomSheetItems),
    onTap: () {
      if (closeSheetOnTap) {
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        } else {
          Navigator.of(context).maybePop();
        }
      }
      onTap();
    },
  );

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
