import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../login/loginscreen.dart';
import '../dashboard_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Get.offAll(() => LoginScreen(), transition: Transition.fade);
      return;
    }

    try {
      // Validate token with the server
      final response = await http.get(
        Uri.parse('http://api.homaexpressco.com/api/v1/portal/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Token is valid, navigate to dashboard
        Get.offAll(() => DashboardView(), transition: Transition.fade);
      } else {
        // Token is invalid or expired
        await prefs.remove('token');
        Get.offAll(() => LoginScreen(), transition: Transition.fade);
      }
    } catch (e) {
      // Handle network errors
      await prefs.remove('token');
      Get.offAll(() => LoginScreen(), transition: Transition.fade);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromRGBO(133, 51, 138, 1).withOpacity(0.1),
                const Color.fromRGBO(133, 51, 138, 1).withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/main-logo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(133, 51, 138, 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 