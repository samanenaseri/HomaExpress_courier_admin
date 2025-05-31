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
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.logoPurple,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 