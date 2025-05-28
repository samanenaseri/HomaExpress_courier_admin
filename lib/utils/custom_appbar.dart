import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDrawer;
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  late final AuthController _authController;

  CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showDrawer = true,
    this.backgroundColor = const Color.fromRGBO(133, 51, 138, 1),
    this.textColor = Colors.white,
    this.elevation = 0,
  }) {
    _authController = Get.put(AuthController());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'پنل مدیریت',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.logoPurple,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 