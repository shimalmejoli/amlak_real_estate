import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

logoutBottomSheet(BuildContext context) {
  final storage = GetStorage();

  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize180,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          bottom: AppSize.appSize20,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.logout,
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                Text(
                  AppString.logoutString,
                  style: AppStyle.heading5Regular(
                      color: AppColor.descriptionColor),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ),
            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      height: AppSize.appSize49,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.primaryColor),
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Center(
                        child: Text(
                          AppString.noButton,
                          style: AppStyle.heading5Medium(
                              color: AppColor.primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.appSize26),
                // Confirm logout
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Clear saved user and go to login
                      storage.remove('user');
                      Get.offAllNamed(AppRoutes.loginView);
                    },
                    child: Container(
                      height: AppSize.appSize49,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                      ),
                      child: Center(
                        child: Text(
                          AppString.yesButton,
                          style: AppStyle.heading5Medium(
                              color: AppColor.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(bottom: AppSize.appSize10),
          ],
        ),
      );
    },
  );
}
