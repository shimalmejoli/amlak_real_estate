// lib/controller/languages_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class LanguagesController extends GetxController {
  RxInt selectLanguage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved selection or default to English (index 0)
    selectLanguage.value = GetStorage().read(AppString.selectedLanguage) ?? 0;
  }

  void updateLanguage(int index) {
    selectLanguage.value = index;
    GetStorage().write(AppString.selectedLanguage, index);
  }

  // Only English, Arabic, Kurdish
  RxList<String> languagesList = [
    AppString.english,
    AppString.arabic,
    AppString.kurdish,
  ].obs;
}
