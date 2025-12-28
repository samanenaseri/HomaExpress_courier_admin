import 'package:flutter/material.dart';
import 'package:homaexpress_courier_admin/controller/login_controller.dart';
import 'package:get/get.dart';
import 'package:progress_state_button/progress_button.dart';
import '../../utils/component/textfield_widget.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final LoginController _loginController = Get.put(LoginController());
  final Rx<AutovalidateMode> autoValidateMode = AutovalidateMode.disabled.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: _body(),
      ),
    );
  }

  Widget _body() => SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(height: 40),
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.logoPurple.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/login-vector.png',
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: Text(
              'خوش آمدید',
              style: TextStyle(
                fontSize: 25,
                color: AppColors.logoPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        /// 👇 فرم (می‌تونی بعداً autovalidateMode رو هم با Obx واکنش‌گرا کنی)
        Form(
          key: _formkey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 20),
                child: TextFieldWidget(
                  maxLines: 1,
                  controller: _loginController.userNameController,
                  textAlign: TextAlign.left,
                  borderSide: BorderSide.none,
                  icon: Icons.email,
                  labelText: 'ایمیل',
                  obsecureText: false,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'لطفا ایمیل خود را وارد نمایید';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 20),
                child: TextFieldWidget(
                  maxLines: 1,
                  controller: _loginController.passwordController,
                  textAlign: TextAlign.left,
                  borderSide: BorderSide.none,
                  icon: Icons.lock,
                  labelText: 'رمز عبور',
                  obsecureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'لطفا رمز عبور خود را وارد نمایید';
                    }
                    return null;
                  },
                ),
              ),
              _loginButton(
                onPress: () async {
                  if (_formkey.currentState!.validate()) {
                    await _loginController.login(
                      _loginController.userNameController!.text,
                      _loginController.passwordController!.text,
                    );
                  } else {
                    autoValidateMode.value =
                        AutovalidateMode.onUserInteraction;
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// 🔘 دکمه‌ی لاگین متصل به state کنترلر
  /// 🔘 دکمه‌ی لاگین متصل به state کنترلر
  /// 🔘 دکمه‌ی لاگین متصل به state کنترلر، بدون پکیج عجیب
  Widget _loginButton({required VoidCallback onPress}) => Obx(() {
    final state = _loginController.state.value;
    final isLoading = state == ButtonState.loading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.logoPurple,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: isLoading ? null : onPress,
          child: isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'در حال ورود...',
                style: AppTextStyles.loginConfirmButton,
              ),
            ],
          )
              : Text(
            'ورود',
            style: AppTextStyles.loginConfirmButton,
          ),
        ),
      ),
    );
  });




}
