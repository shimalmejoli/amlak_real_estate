import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_font.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/onboard_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class OnboardView extends StatelessWidget {
  OnboardView({super.key});

  final OnboardController onboardController = Get.put(OnboardController());
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: AppSize.appSize60,
              left: AppSize.appSize16,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                Assets.images.appLogo.path,
                width: AppSize.appSize50,
                height: AppSize.appSize50,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    onboardController.currentIndex.value = index;
                  },
                  itemCount: onboardController.titles.length,
                  itemBuilder: (context, index) {
                    return Obx(() => AnimatedSwitcher(
                          duration:
                              const Duration(milliseconds: AppSize.size500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: buildPage(index,
                              key: ValueKey<int>(
                                  onboardController.currentIndex.value)),
                        ));
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Obx(() => buildBottomSection()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(int index, {required Key key}) {
    return Column(
      key: key,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
          margin: const EdgeInsets.only(top: AppSize.appSize26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                onboardController.titles[index],
                style: const TextStyle(
                  fontSize: AppSize.appSize30,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFont.interBold,
                  color: AppColor.textColor,
                ),
              ),
              Text(
                onboardController.subtitles[index],
                style:
                    AppStyle.heading3Medium(color: AppColor.descriptionColor),
              ).paddingOnly(top: AppSize.appSize14),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: AppSize.appSize40),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSize.appSize16),
                topRight: Radius.circular(AppSize.appSize16),
              ),
              image: DecorationImage(
                image: AssetImage(onboardController.images[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBottomSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSize.appSize26),
      padding: const EdgeInsets.all(AppSize.appSize6),
      height: AppSize.appSize68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize50),
        color: AppColor.textColor.withValues(alpha: AppSize.appSizePoint90),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            onboardController.currentIndex.value ==
                    onboardController.titles.length - 1
                ? AppString.getStartButton
                : AppString.nextButton,
            style: AppStyle.heading3Medium(color: AppColor.whiteColor),
          ).paddingOnly(
            left: AppSize.appSize10,
            right: onboardController.currentIndex.value ==
                    onboardController.titles.length - 1
                ? AppSize.appSize22
                : AppSize.appSize60,
          ),
          GestureDetector(
            onTap: () {
              if (onboardController.currentIndex.value <
                  onboardController.titles.length - 1) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Get.offAllNamed(AppRoutes.loginView);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSize.appSize16),
              decoration: const BoxDecoration(
                color: AppColor.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  Assets.images.nextButton.path,
                  width: AppSize.appSize24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
