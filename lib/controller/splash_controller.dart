// lib/controller/splash_controller.dart

import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    Future.delayed(
      const Duration(seconds: AppSize.size4),
      () {
        // mark splash viewed
        _storage.write('hasSeenSplash', true);
        // skip onboarding & login, go straight to home
        Get.offAllNamed(AppRoutes.bottomBarView);
      },
    );
  }
}
