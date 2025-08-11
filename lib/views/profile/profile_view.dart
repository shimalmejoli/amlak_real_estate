// lib/views/profile/profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/controller/profile_controller.dart';
import 'package:amlak_real_estate/controller/translation_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/views/profile/widgets/delete_account_bottom_sheet.dart';
import 'package:amlak_real_estate/views/profile/widgets/finding_us_helpful_bottom_sheet.dart';
import 'package:amlak_real_estate/views/profile/widgets/logout_bottom_sheet.dart';

class ProfileView extends StatelessWidget {
  ProfileView({Key? key}) : super(key: key);

  final _storage = GetStorage();
  final ProfileController profileController = Get.put(ProfileController());
  final TranslationController translationController =
      Get.put(TranslationController());

  @override
  Widget build(BuildContext context) {
    // If there's no 'user' in storage, kick back to login immediately:
    if (!_storage.hasData('user')) {
      // schedule navigation after build
      Future.microtask(() => Get.offAllNamed(AppRoutes.loginView));
      // return an empty placeholder while redirection happens
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: _buildAppBar(),
      body: _buildProfileContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            final bc = Get.find<BottomBarController>();
            bc.pageController.jumpToPage(0);
          },
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Obx(() => Text(
            translationController.translate(AppString.profile),
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          )),
    );
  }

  Widget _buildProfileContent() {
    return Obx(() {
      final u = profileController.user.value;
      if (u == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: AppSize.appSize10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar, Name, Role, Edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        u.avatarUrl,
                        width: AppSize.appSize68,
                        height: AppSize.appSize68,
                        fit: BoxFit.cover,
                      ),
                    ).paddingOnly(right: AppSize.appSize16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u.name,
                          style: AppStyle.heading3Medium(
                              color: AppColor.textColor),
                        ),
                        Text(
                          u.role.capitalizeFirst ?? u.role,
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.editProfileView,
                      arguments: u.id,
                    );
                  },
                  child: Obx(() => Text(
                        translationController.translate(AppString.editProfile),
                        style: AppStyle.heading5Medium(
                            color: AppColor.primaryColor),
                      )),
                ),
              ],
            ),

            // Options list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: AppSize.appSize36),
              itemCount: profileController.profileOptionImageList.length,
              separatorBuilder: (_, __) => Divider(
                color: AppColor.descriptionColor
                    .withValues(alpha: AppSize.appSizePoint4),
                height: 0,
                thickness: AppSize.appSizePoint7,
              ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize26),
              itemBuilder: (context, index) {
                final img = profileController.profileOptionImageList[index];
                final title = profileController.profileOptionTitleList[index];
                return GestureDetector(
                  onTap: () {
                    switch (index) {
                      case 0:
                        Get.toNamed(AppRoutes.responsesView);
                        break;
                      case 1:
                        Get.toNamed(AppRoutes.languagesView);
                        break;
                      case 2:
                        Get.toNamed(AppRoutes.communitySettingsView);
                        break;
                      case 3:
                        Get.toNamed(AppRoutes.feedbackView);
                        break;
                      case 4:
                        findingUsHelpfulBottomSheet(context);
                        break;
                      case 5:
                        logoutBottomSheet(context);
                        break;
                      case 6:
                        deleteAccountBottomSheet(context);
                        break;
                    }
                  },
                  child: Row(
                    children: [
                      Image.asset(img, width: AppSize.appSize20)
                          .paddingOnly(right: AppSize.appSize12),
                      Obx(() => Text(
                            translationController.translate(title),
                            style: AppStyle.heading5Regular(
                                color: AppColor.textColor),
                          )),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
