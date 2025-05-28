import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/pickup_controller.dart';
import '../utils/constants.dart';
import '../utils/custom_appbar.dart';
import '../utils/drawer_widget.dart';
import 'package:intl/intl.dart';


class PickupView extends StatelessWidget {
  final PickupController controller = Get.put(PickupController());
  bool expanded=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
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
            itemCount: controller.pickups.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.pickups.length) {
                if (controller.isLoading.value) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ));
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
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

                            onPressed: (){
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                backgroundColor: Colors.white,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _bottomSheetItems(context,Icons.photo,'آپلود کارت ملی'),
                                      _bottomSheetItems(context,Icons.payment,'پرداخت'),
                                      _bottomSheetItems(context,Icons.print,'چاپ رسید'),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(30, 35),
                              backgroundColor: AppColors.logoPurple.withValues(alpha: 0.1),
                              foregroundColor: AppColors.logoPurple,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  side: BorderSide(width: 1.0,color: AppColors.mainPurple,)
                              ),
                              elevation: 0,
                            ),


                            child: Icon(Icons.settings)),
                      ),

                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Container(
                       // margin: EdgeInsets.only(top: 8),
                       // padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        // decoration: BoxDecoration(
                        //   color: pickup.status == 'pending' ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                        //   borderRadius: BorderRadius.circular(20),
                        //   border: Border.all(
                        //     color: pickup.status == 'pending' ? Colors.orange : Colors.green,
                        //     width: 1,
                        //   ),
                        // ),
                      //   child: Text(
                      //     pickup.status,
                      //     style: TextStyle(
                      //       color: pickup.status == 'pending' ? Colors.orange : Colors.green,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ],
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
                                      Icon(Icons.person_outline, color: AppColors.logoPurple),
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
                                  _buildInfoRow('نام', pickup.senderAddress!.name),
                                  _buildInfoRow('موبایل', pickup.senderAddress!.mobile),
                                  _buildInfoRow('آدرس', pickup.senderAddress!.address),
                                  if (pickup.senderAddress!.city != null)
                                    _buildInfoRow('شهر', pickup.senderAddress!.city!.faName),
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
                                      Icon(Icons.person_outline, color: AppColors.logoPurple),
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
                                  _buildInfoRow('نام', pickup.receiverAddress!.name),
                                  _buildInfoRow('موبایل', pickup.receiverAddress!.mobile),
                                  _buildInfoRow('آدرس', pickup.receiverAddress!.address),
                                  if (pickup.receiverAddress!.city != null)
                                    _buildInfoRow('شهر', pickup.receiverAddress!.city!.faName),
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
                                    Icon(Icons.info_outline, color: AppColors.logoPurple),
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
                                _buildInfoRow('شماره سفارش', pickup.orderNumber),
                                _buildInfoRow('نوع سفارش', pickup.orderType),
                                _buildInfoRow('قیمت کل', '${pickup.totalPrice} تومان'),
                                _buildInfoRow('مبلغ COD', '${pickup.codAmount} تومان'),
                                if (pickup.courierName != null)
                                  _buildInfoRow('نام پیک', pickup.courierName!),
                                if (pickup.numberBillOfLading != null)
                                  _buildInfoRow('شماره بارنامه', pickup.numberBillOfLading!),
                                _buildInfoRow('تاریخ ایجاد', DateFormat('yyyy/MM/dd HH:mm').format(pickup.createdAt)),
                                _buildInfoRow('آخرین بروزرسانی', DateFormat('yyyy/MM/dd HH:mm').format(pickup.updatedAt)),
                              ],
                            ),
                          ),
                          if (pickup.status == 'pending')
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                onPressed: () => controller.completePickup(pickup.id),
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
    );
  }
  Widget _bottomSheetItems(context,image,text)=>ListTile(
    leading: Icon(image,color: AppColors.logoGold,),
    title: Text(text,style: AppTextStyles.bottomSheetItems,),
    onTap: () {
      Navigator.pop(context);
      // Add your logic here
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
