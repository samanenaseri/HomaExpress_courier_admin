import 'package:flutter/material.dart';
import 'package:homaexpress_courier_admin/controller/logincontroller.dart';
import 'package:get/get.dart';
import 'package:progress_state_button/progress_button.dart';

import '../../utils/component/textfield_widget.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatelessWidget {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final LoginController _loginController = Get.put(LoginController());
  final Rx<AutovalidateMode> autoValidateMode = AutovalidateMode.disabled.obs;
  //final Color mainColor = const Color.fromRGBO(133, 51, 138, 1);

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
                //fit: BoxFit.contain,
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
            Form(
              key: _formkey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                      },
                    ),
                  ),
                  _searchBox(
                    onPress: () async {
                      if (_formkey.currentState!.validate()) {
                        await _loginController.login(
                          _loginController.userNameController!.text,
                          _loginController.passwordController!.text,
                        );
                      } else {
                        autoValidateMode.value = AutovalidateMode.onUserInteraction;
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _searchBox({required VoidCallback onPress}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: ProgressButton(
          stateWidgets: {
            ButtonState.idle: Text('ورود', style: AppTextStyles.loginConfirmButton),
            ButtonState.loading: Text('انتظار..', style: AppTextStyles.loginConfirmButton),
            ButtonState.fail: Text('خطا', style: AppTextStyles.loginConfirmButton),
            ButtonState.success: Text('موفقیت', style: AppTextStyles.loginConfirmButton),
          },
          stateColors: {
            ButtonState.idle: AppColors.logoPurple,
            ButtonState.loading: AppColors.logoPurple.withOpacity(0.8),
            ButtonState.fail: Colors.red,
            ButtonState.success: Colors.green,
          },
          state: ButtonState.idle,
          onPressed: onPress,
        ),
      );
}

