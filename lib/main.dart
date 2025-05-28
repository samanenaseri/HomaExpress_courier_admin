import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:homaexpress_courier_admin/utils/constants.dart';
import 'package:homaexpress_courier_admin/view/login/loginscreen.dart';
import 'package:homaexpress_courier_admin/view/splash/splashscreen.dart';
import 'package:homaexpress_courier_admin/view/dashboard_view.dart';
import 'package:homaexpress_courier_admin/view/pickup_view.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => Sizer(
    builder: (context, orientation, deviceType) => Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ExpressCourier',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale("fa")],
        locale: const Locale("fa", "IR"),
        theme: AppThemes.defaultTheme,
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const SplashScreen()),
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/dashboard', page: () => DashboardView()),
          GetPage(name: '/pickups', page: () => PickupView()),
        ],
      ),
    ),
  );
}

