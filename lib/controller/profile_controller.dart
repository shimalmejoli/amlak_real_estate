import 'package:get/get.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/controller/login_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class ProfileController extends GetxController {
  // 1️⃣ Grab the current user from LoginController
  final LoginController _loginC = Get.find<LoginController>();
  Rx<User?> user = Rx<User?>(null);

  // 2️⃣ Emoji feedback (Finding us helpful)
  RxInt selectEmoji = 0.obs;
  void updateEmoji(int idx) => selectEmoji.value = idx;

  // 3️⃣ Profile menu options
  RxList<String> profileOptionImageList = [
    Assets.images.profileOption1.path,
    Assets.images.profileOption2.path,
    Assets.images.profileOption3.path,
    Assets.images.profileOption4.path,
    Assets.images.profileOption5.path,
    Assets.images.profileOption6.path,
    Assets.images.profileOption6.path,
  ].obs;

  RxList<String> profileOptionTitleList = [
    AppString.viewResponses,
    AppString.languages,
    AppString.communicationSettings,
    AppString.shareFeedback,
    AppString.areYouFindingUsHelpful,
    AppString.logout,
    AppString.deleteAccount,
  ].obs;

  // 4️⃣ “Finding us helpful” bottom‐sheet data
  RxList<String> findingUsImageList = [
    Assets.images.poor.path,
    Assets.images.neutral.path,
    Assets.images.good.path,
    Assets.images.excellent.path,
  ].obs;

  RxList<String> findingUsTitleList = [
    AppString.poor,
    AppString.neutral,
    AppString.good,
    AppString.excellent,
  ].obs;

  @override
  void onInit() {
    super.onInit();
    // Seed our local user from the login
    user.value = _loginC.user.value;
  }
}
