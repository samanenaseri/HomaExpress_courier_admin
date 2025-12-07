import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:progress_state_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  TextEditingController? userNameController;
  TextEditingController? passwordController;
  Rx<ButtonState> state = ButtonState.idle.obs;
  String token = '';

  @override
  void onInit() {
    userNameController = TextEditingController();
    passwordController = TextEditingController();
    super.onInit();
  }

  login(String email, String password) async {
    // ⬅️ اول دکمه رو می‌بریم روی لودینگ
    state.value = ButtonState.loading;

    Map<String, String> header = {"Content-Type": "application/json"};
    Map<String, String> body = {"email": email, "password": password};
    var url = Uri.parse("https://api.homaexpressco.com/api/v1/login");

    try {
      var response = await http.post(
        url,
        body: convert.jsonEncode(body),
        headers: header,
      );

      print('LOGIN STATUS = ${response.statusCode}');
      print('LOGIN BODY   = ${response.body}');
      // ✅ لاگین موفق
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        token = jsonResponse['data']['token'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        print('SAVED TOKEN IN PREFS = ${prefs.getString('token')}');

        state.value = ButtonState.success;
        Get.offAllNamed('/dashboard');
        return;
      }

      // ✅ هندل ریدایرکت (در صورت وجود)
      if (response.statusCode == 301 || response.statusCode == 302) {
        String redirectUrl = response.headers['location'] ?? '';
        if (redirectUrl.isNotEmpty) {
          response = await http.post(
            Uri.parse(redirectUrl),
            body: convert.jsonEncode(body),
            headers: header,
          );

          if (response.statusCode == 200) {
            var jsonResponse = convert.jsonDecode(response.body);
            token = jsonResponse['data']['token'];

            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);

            state.value = ButtonState.success;
            Get.offAllNamed('/dashboard');
            return;
          }
        }
      }

      // ❌ یوزر یا پسورد اشتباه (معمولاً 401 یا 404)
      if (response.statusCode == 401 || response.statusCode == 404) {
        state.value = ButtonState.fail;
        Get.snackbar('خطای ورود', 'ایمیل یا رمز عبور اشتباه است',
            snackPosition: SnackPosition.BOTTOM);
      }
      // ❌ مشکل فیلترشکن / گیت‌وی
      else if (response.statusCode == 504) {
        state.value = ButtonState.fail;
        Get.snackbar('خطا', 'لطفا فیلترشکن خود را خاموش کنید',
            snackPosition: SnackPosition.BOTTOM);
      }
      // ❌ هر خطای دیگری
      else {
        state.value = ButtonState.fail;
        Get.snackbar(
          'خطا',
          'ورود با خطا مواجه شد. (کد: ${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // ❌ خطای شبکه / استثنا
      state.value = ButtonState.fail;
      Get.snackbar(
        'خطای شبکه',
        'مشکلی در ارتباط با سرور پیش آمد. دوباره تلاش کنید.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // اگر موفق نشدیم لاگین کنیم، دکمه رو بعد از یه لحظه برگردون به idle
      if (state.value != ButtonState.success) {
        await Future.delayed(const Duration(milliseconds: 500));
        state.value = ButtonState.idle;
      }
    }
  }
}
