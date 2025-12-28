import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:homaexpress_courier_admin/utils/constants.dart';
import 'package:homaexpress_courier_admin/utils/custom_appbar.dart';
import 'package:homaexpress_courier_admin/utils/drawer_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// ❗ فعلاً دمو: بعداً اینارو از API / SharedPreferences / GetX بگیر
    final String fullName = 'نام و نام خانوادگی';
    final String email = 'user@example.com';

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: CustomAppBar(
        actions:[
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white,),
            onPressed: () {

               Get.back();
            },
          ),
        ],
        title: 'Profile',
        backgroundColor: AppColors.logoGold,
        textColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              /// 🧑‍🦲 آواتار + آیکن آپلود
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                    AppColors.logoPurple.withOpacity(0.08),
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.logoPurple,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Material(
                      color: AppColors.logoPurple,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          // TODO: اینجا بعداً پیکر انتخاب عکس رو باز کن
                          // مثلاً: ImagePicker / فایل‌پیکر و ...
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// نام و ایمیل
              Text(
                fullName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.logoPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),

              /// کارت اطلاعات کاربر
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        label: 'نام و نام خانوادگی',
                        value: fullName,
                        icon: Icons.person,
                      ),
                      const Divider(height: 16),
                      _buildInfoRow(
                        label: 'ایمیل',
                        value: email,
                        icon: Icons.email,
                      ),
                      // اگر خواستی بعداً تلفن هم اضافه کن
                      // const Divider(height: 16),
                      // _buildInfoRow(
                      //   label: 'شماره تلفن',
                      //   value: phone,
                      //   icon: Icons.phone,
                      // ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// دکمه‌ی ویرایش پروفایل
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: بعداً فرم ویرایش پروفایل/دیالوگ رو اینجا صدا بزن
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ویرایش پروفایل',
                    style: AppTextStyles.loginConfirmButton,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.logoPurple,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
