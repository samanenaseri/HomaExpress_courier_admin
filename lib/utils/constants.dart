
import 'package:flutter/material.dart';

class AppColors{
  static Color primary= const Color.fromRGBO(255, 255, 255, 1);
  static Color mainPurple= const Color.fromRGBO(103, 58, 183, 1);
  static Color logoPurple= const Color.fromRGBO(132, 50, 137, 1);
  static Color logoGold= const Color.fromRGBO(210, 160, 67, 1);
  static Color divider= const Color.fromRGBO(0, 0, 0, 0.5);
}

class AppThemes{
  static ThemeData defaultTheme= ThemeData(
    dividerColor: AppColors.divider,
    primaryColor: AppColors.primary,
    fontFamily: 'YekanBakh'
  );
}
class AppTextStyles{
static TextStyle textField =  TextStyle(fontSize: 15, color: AppColors.mainPurple);
static const TextStyle loginConfirmButton =TextStyle(color: Colors.white, fontWeight: FontWeight.w700,fontSize: 22);
static TextStyle bottomSheetItems=TextStyle(color:AppColors.logoPurple,fontSize: 15,fontWeight: FontWeight.w700);

}