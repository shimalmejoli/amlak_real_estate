// lib/app.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/login_controller.dart';
import 'package:amlak_real_estate/controller/translation_controller.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure storage is ready before anything else
    // (your main.dart already does this)
    final TranslationController tCtrl = Get.put(TranslationController());
    final LoginController loginCtrl = Get.put(LoginController());

    return Obx(() {
      // Determine direction: Arabic or Kurdish => RTL, else LTR
      final isRtl = tCtrl.selectedLanguage.value == AppString.ar ||
          tCtrl.selectedLanguage.value == AppString.ku;

      return GetMaterialApp(
        title: AppString.appName,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.fadeIn,

        // Inject your global controllers
        initialBinding: BindingsBuilder(() {
          Get.put(loginCtrl);
          Get.put(tCtrl);
        }),

        // Wrap everything in a Directionality that updates reactively
        builder: (context, child) => Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),

        // Always start at splash
        initialRoute: AppRoutes.splashView,
        getPages: AppRoutes.pages,
      );
    });
  }
}
