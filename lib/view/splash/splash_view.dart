
import '../../../utils/constants.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../controller/splashcontroller.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  Animation<double>? _animation;
  AnimationController? _animationController;
  @override
  void initState() {
    // TODO: implement initState
    _animationController= AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _animation = Tween(begin: 0.0,end: 64.0).animate(CurvedAnimation(parent: _animationController!, curve: const Interval(0,1,curve: Curves.easeIn)));
    super.initState();
    _animationController!.forward();
    _animationController!.addListener(() { setState(() {
    });});
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    return Scaffold(
        backgroundColor: AppColors.logoPurple,
        body: Center(
          child:Text('Express',style: TextStyle(fontSize: _animation!.value,color: AppColors.logoGold,fontWeight: FontWeight.bold),
          ),)
    );
  }
}
