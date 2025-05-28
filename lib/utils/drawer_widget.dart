import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'constants.dart';

class CustomDrawer extends StatelessWidget {
  final AuthController _authController = Get.put(AuthController());

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: AppColors.logoPurple,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       AppColors.logoPurple.withValues(alpha:1),
        //       AppColors.logoPurple.withValues(alpha:0.5),
        //     ],
        //   ),
        // ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.logoPurple,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.logoPurple,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'پنل مدیریت',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined, color: Colors.white),
              title: Text(
                'داشبورد',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                Get.toNamed('/dashboard');
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory_2_outlined, color: Colors.white),
              title: Text(
                'سفارشات',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                Get.toNamed('/pickups');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.white),
              title: Text(
                'پروفایل',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                Get.toNamed('/profile');
              },
            ),
            Divider(color: Colors.white24),
            ListTile(
              leading: Icon(Icons.logout_outlined, color: Colors.white),
              title: Text(
                'خروج',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    title: Text('خروج از حساب کاربری'),
                    content: Text('آیا از خروج از حساب کاربری خود اطمینان دارید؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('انصراف'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          _authController.logout();
                        },
                        child: Text('خروج'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 