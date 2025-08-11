import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class OnboardController extends GetxController {
  RxInt currentIndex = 0.obs;

  List<String> images = [
    Assets.images.onboard1.path,
    Assets.images.onboard2.path,
    Assets.images.onboard3.path,
  ];

  List<String> titles = [
    AppString.onboardTitle1,
    AppString.onboardTitle2,
    AppString.onboardTitle3,
  ];

  List<String> subtitles = [
    AppString.onboardSubTitle1,
    AppString.onboardSubTitle2,
    AppString.onboardSubTitle3,
  ];

  void nextPage() {
    if (currentIndex < images.length - AppSize.size1) {
      currentIndex++;
    } else {
      Get.offAllNamed(AppRoutes.loginView);
    }
  }

  String get nextButtonText {
    return currentIndex.value == images.length - AppSize.size1
        ? AppString.getStartButton
        : AppString.nextButton;
  }
}
