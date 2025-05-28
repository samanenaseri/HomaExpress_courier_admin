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

  login(email, password) async {
    Map<String, String> header = {"Content-Type": "application/json"};

    Map<String, String> body = {"email": email, "password": password};
    var url = Uri.parse("http://api.homaexpressco.com/api/v1/login");
    var response = await http.post(
      url,
      body: convert.jsonEncode(body),
      headers: header,
    );
    state.value = ButtonState.loading;

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      token = jsonResponse['data']['token'];
      
      final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
      final SharedPreferences prefs = await _prefs;
      await prefs.setString('token', token);
      
      state.value = ButtonState.success;
      Get.offAllNamed('/dashboard');
    } else if (response.statusCode == 301 || response.statusCode == 302) {
      String redirectUrl = response.headers['location'] ?? '';
      if (redirectUrl.isNotEmpty) {
        response = await http.post(
          Uri.parse(redirectUrl),
          body: convert.jsonEncode(body),
          headers: header,
        );
      } else {
        state.value = ButtonState.fail;
        Get.snackbar('خطا', 'ورود با خطا مواجه شد');
      }
    } else if(response.statusCode== 504){
      state.value = ButtonState.fail;
      Get.snackbar('خطا', 'لطفا فیلترشکن خود را خاموش کنید');
    }
  }
}
