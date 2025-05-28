import 'package:flutter/material.dart';

import '../constants.dart';
class TextFieldWidget extends StatelessWidget {
  final labelText;
  final obsecureText;
  final controller;
  final icon;
  final onChange;
  final keyboardType;
  final maxLines;
  final borderSide;
  final textAlign;
  final validator;
   TextFieldWidget({this.borderSide,this.controller,this.icon,this.keyboardType,this.labelText,this.maxLines,this.obsecureText,this.onChange,this.textAlign,this.validator});
  @override
  FocusNode myFocusNode = new FocusNode();
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        textAlign: textAlign,
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style:AppTextStyles.textField,
        cursorColor: myFocusNode.hasFocus?AppColors.mainPurple : Colors.grey,
        onChanged: onChange,
        obscureText: obsecureText,
        decoration: InputDecoration(
          filled: true,
          labelText: labelText,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? AppColors.mainPurple : AppColors.mainPurple,
              fontSize: myFocusNode.hasFocus? 15:15
          ),
          suffixIcon: Icon(icon, color: myFocusNode.hasFocus? AppColors.mainPurple:AppColors.mainPurple,),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: borderSide,
            borderRadius: BorderRadius.circular(10),
          )
        ),
      ),
    );
  }
}
