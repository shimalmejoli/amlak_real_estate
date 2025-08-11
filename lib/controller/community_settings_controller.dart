import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class CommunitySettingsController extends GetxController {
  RxBool isSwitch1 = false.obs;
  RxBool isSwitch2 = false.obs;

  RxList<String> communitySettingsList = [
    AppString.receivePromotional,
    AppString.receivePushNotification,
  ].obs;
}
