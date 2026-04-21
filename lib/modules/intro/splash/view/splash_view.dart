import 'package:crud_getx_demo/core/constants/asset_constants.dart';
import 'package:crud_getx_demo/modules/intro/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetWidget<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(AssetConstants.splashAnimate, fit: BoxFit.cover),
      ),
    );
  }
}
