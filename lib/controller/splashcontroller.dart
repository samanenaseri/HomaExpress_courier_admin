import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homaexpress_courier_admin/view/login/loginscreen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController{
 void onInit(){

 }
}

void _handlScreen() async{
 await Future.delayed(Duration(seconds: 2));
 final Future<SharedPreferences> _prefs= SharedPreferences.getInstance();
 final SharedPreferences prefs= await _prefs;
 String? userToken=prefs.getString('userToken');
 if(userToken==null){
  Get.off(()=>LoginScreen(), transition: Transition.zoom,duration: Duration(seconds: 1));
 }else{

 }
}
checkUserToken(String userToken) async{
 Map<String,String> header={
  "Content-type":"application/json",
  "token": userToken,
 };
 var url= Uri.parse("http://api.homaexpressco.com");
}