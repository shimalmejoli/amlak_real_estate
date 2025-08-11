import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/splash_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final SplashController splashController = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: buildSplash(),
    );
  }

  Widget buildSplash() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            Assets.images.appLogo.path,
            width: AppSize.appSize74,
            height: AppSize.appSize74,
          ),
        ),
        Text(
          AppString.appLogoName,
          style: AppStyle.appHeading(
            color: AppColor.primaryColor,
            letterSpacing: AppSize.appSize3,
          ),
        ).paddingOnly(top: AppSize.appSize3),
      ],
    );
  }
}
