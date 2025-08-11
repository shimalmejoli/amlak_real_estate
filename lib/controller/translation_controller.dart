// lib/controller/translation_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class TranslationController extends GetxController {
  // Only three locales: English, Arabic, Kurdish
  final Map<String, Map<String, String>> translation = {
    AppString.en: {
      'Profile': 'Profile',
      'Francis Zieme': 'Francis Zieme',
      'Edit Profile': 'Edit Profile',
      'View Responses': 'View Responses',
      'Languages': 'Languages',
      'Communication Settings': 'Communication Settings',
      'Share Feedback': 'Share Feedback',
      'Are You Finding us Helpful?': 'Are You Finding us Helpful?',
      'Logout': 'Logout',
      'Delete Account': 'Delete Account',
    },
    AppString.ar: {
      'Profile': 'الملف الشخصي',
      'Francis Zieme': 'فرانسيس زيمي',
      'Edit Profile': 'تعديل الملف الشخصي',
      'View Responses': 'عرض الردود',
      'Languages': 'اللغات',
      'Communication Settings': 'إعدادات الاتصال',
      'Share Feedback': 'شارك التعليقات',
      'Are You Finding us Helpful?': 'هل تجدنا مفيدين؟',
      'Logout': 'تسجيل الخروج',
      'Delete Account': 'حذف الحساب',
    },
    AppString.ku: {
      'Profile': 'پرۆفایل',
      'Francis Zieme': 'فرانسیس زیەمە',
      'Edit Profile': 'دەستکاری پرۆفایل',
      'View Responses': 'بینینی وەڵامەکان',
      'Languages': 'زمان',
      'Communication Settings': 'ڕێکخستنەکانی پەیوەندی',
      'Share Feedback': 'هاوبەشی پاشخست',
      'Are You Finding us Helpful?': 'ئایا ئێمە یارمەتیت کردووین؟',
      'Logout': 'چوونە دەرەوە',
      'Delete Account': 'سڕینەوەی هەژمار',
    },
  };

  RxString selectedLanguage = AppString.en.obs;

  // Only the same three codes
  RxList<String> languageList = [
    AppString.en,
    AppString.ar,
    AppString.ku,
  ].obs;

  final GetStorage storage = GetStorage();

  @override
  void onInit() {
    selectedLanguage.value = storage.read(AppString.languages) ?? AppString.en;
    super.onInit();
  }

  String translate(String key) =>
      translation[selectedLanguage.value]?[key] ?? key;

  void changeLanguage(String language) {
    selectedLanguage(language);
    storage.write(AppString.languages, language);
    update();
  }
}
