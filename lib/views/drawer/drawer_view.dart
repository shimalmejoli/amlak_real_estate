// lib/views/drawer/drawer_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amlak_real_estate/common/common_rich_text.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/controller/drawer_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/model/text_segment_model.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/views/profile/widgets/finding_us_helpful_bottom_sheet.dart';
import 'package:amlak_real_estate/views/profile/widgets/logout_bottom_sheet.dart';

class DrawerView extends StatelessWidget {
  DrawerView({Key? key}) : super(key: key);

  final SlideDrawerController drawerController =
      Get.put(SlideDrawerController());
  final GetStorage _storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    // Read user info
    final userMap = _storage.read('user') as Map<String, dynamic>?;
    final userName = (userMap != null &&
            userMap['name'] != null &&
            (userMap['name'] as String).trim().isNotEmpty)
        ? userMap['name'] as String
        : 'Guest';
    final userRole = (userMap != null &&
            userMap['role'] != null &&
            (userMap['role'] as String).trim().isNotEmpty)
        ? userMap['role'] as String
        : 'Guest';

    return Drawer(
      backgroundColor: AppColor.whiteColor,
      width: AppSize.appSize285,
      elevation: AppSize.appSize0,
      shape: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppSize.appSize12),
          bottomRight: Radius.circular(AppSize.appSize12),
        ),
        borderSide: BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: name, role, manage profile, and close button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name or Guest
                    Text(
                      userName,
                      style: AppStyle.heading3Medium(color: AppColor.textColor),
                    ),
                    // Inline role + separator + Manage Profile link
                    CommonRichText(
                      segments: [
                        TextSegment(
                          text: userRole,
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                          text: AppString.lining,
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                          text: AppString.manageProfile,
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor),
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoutes.editProfileView);
                          },
                        ),
                      ],
                    ).paddingOnly(top: AppSize.appSize4),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(
                  Assets.images.close.path,
                  width: AppSize.appSize24,
                  height: AppSize.appSize24,
                ),
              ),
            ],
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),

          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint3),
            height: AppSize.appSize0,
            thickness: AppSize.appSizePoint7,
          ).paddingOnly(top: AppSize.appSize26),

          // Drawer primary navigation
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: AppSize.appSize36,
                bottom: AppSize.appSize10,
              ),
              children: [
                // Main items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: AppSize.appSize16),
                  itemCount: drawerController.drawerList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        switch (index) {
                          case 0:
                            Get.toNamed(AppRoutes.notificationView);
                            break;
                          case 1:
                            Get.toNamed(AppRoutes.searchView);
                            break;
                          case 2:
                            Get.toNamed(AppRoutes.postPropertyView);
                            break;
                          case 3:
                            Get.find<BottomBarController>()
                                .pageController
                                .jumpToPage(AppSize.size1);
                            break;
                          case 4:
                            Get.toNamed(AppRoutes.responsesView);
                            break;
                        }
                      },
                      child: Text(
                        drawerController.drawerList[index],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),

                // "Your Property Search" section
                Text(
                  AppString.yourPropertySearch,
                  style: AppStyle.heading6Bold(color: AppColor.primaryColor),
                ).paddingOnly(top: AppSize.appSize10, left: AppSize.appSize16),
                Divider(
                  color: AppColor.primaryColor
                      .withValues(alpha: AppSize.appSizePoint50),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize16, bottom: AppSize.appSize16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      top: AppSize.appSize10,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16),
                  itemCount: drawerController.drawer2List.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        switch (index) {
                          case 0:
                            Get.toNamed(AppRoutes.recentActivityView);
                            break;
                          case 1:
                            Get.toNamed(AppRoutes.viewedPropertyView);
                            break;
                          case 2:
                            Get.find<BottomBarController>()
                                .pageController
                                .jumpToPage(AppSize.size3);
                            break;
                          case 3:
                            Get.toNamed(AppRoutes.contactPropertyView);
                            break;
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            drawerController.drawer2List[index],
                            style: AppStyle.heading5Medium(
                                color: AppColor.textColor),
                          ),
                          Text(
                            drawerController.searchPropertyNumberList[index],
                            style: AppStyle.heading5Medium(
                                color: AppColor.primaryColor),
                          ),
                        ],
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),

                Divider(
                  color: AppColor.primaryColor
                      .withValues(alpha: AppSize.appSizePoint50),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize10, bottom: AppSize.appSize36),

                // Third section: help, agents, offices, reads
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: AppSize.appSize16),
                  itemCount: drawerController.drawer3List.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Get.back();
                        switch (index) {
                          case 0:
                            // first item stays the same
                            break;
                          case 1:
                            Get.toNamed(AppRoutes.agentsListView);
                            break;
                          case 2:
                            Get.toNamed(AppRoutes.officeListView);
                            break;
                          case 3:
                            Get.toNamed(AppRoutes.interestingReadsView);
                            break;
                        }
                      },
                      child: Text(
                        drawerController.drawer3List[index],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),

                Text(
                  AppString.exploreProperties,
                  style: AppStyle.heading6Bold(color: AppColor.primaryColor),
                ).paddingOnly(top: AppSize.appSize10, left: AppSize.appSize16),
                Divider(
                  color: AppColor.primaryColor
                      .withValues(alpha: AppSize.appSizePoint50),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize16, bottom: AppSize.appSize20),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoutes.searchView);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize6),
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  Assets.images.residential.path,
                                  width: AppSize.appSize20,
                                ),
                              ),
                              Center(
                                child: Text(
                                  AppString.residentialProperties,
                                  textAlign: TextAlign.center,
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
                                ),
                              ).paddingOnly(top: AppSize.appSize6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSize.appSize16),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(AppSize.appSize6),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                Assets.images.buildings.path,
                                width: AppSize.appSize20,
                              ),
                            ),
                            Center(
                              child: Text(
                                AppString.commercialProperties,
                                textAlign: TextAlign.center,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.textColor),
                              ),
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).paddingOnly(
                    left: AppSize.appSize16, right: AppSize.appSize16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    top: AppSize.appSize36,
                  ),
                  itemCount: drawerController.drawer4List.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == AppSize.size0) {
                          Get.back();
                          Get.toNamed(AppRoutes.termsOfUseView);
                        } else if (index == AppSize.size1) {
                          Get.back();
                          Get.toNamed(AppRoutes.feedbackView);
                        } else if (index == AppSize.size2) {
                          Get.back();
                          findingUsHelpfulBottomSheet(context);
                        } else if (index == AppSize.size3) {
                          Get.back();
                          logoutBottomSheet(context);
                        }
                      },
                      child: Text(
                        drawerController.drawer4List[index],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(top: AppSize.appSize60),
    );
  }
}
