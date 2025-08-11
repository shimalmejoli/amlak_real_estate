// lib/views/login/login_view.dart

import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/views/login/widgets/login_coutry_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/common/common_button.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/login_controller.dart';
import 'package:amlak_real_estate/controller/login_country_picker_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);

  final LoginController loginController = Get.put(LoginController());
  final LoginCountryPickerController loginCountryPickerController =
      Get.put(LoginCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSize.appSize16),
          child: GestureDetector(
            onTap: () => Get.offNamed(AppRoutes.bottomBarView),
            child: Image.asset(Assets.images.backArrow.path),
          ),
        ),
        leadingWidth: AppSize.appSize40,
        title: Text(
          "Back to Home page",
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
      ),
      body: _buildLoginFields(context),
      bottomNavigationBar: _buildFooter(),
    );
  }

  Widget _buildLoginFields(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppString.login,
              style: AppStyle.heading1(color: AppColor.textColor)),
          Text(AppString.loginString,
                  style: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor))
              .paddingOnly(top: AppSize.appSize12),

          // Phone field
          Obx(() {
            final hasFocus = loginController.hasFocus.value;
            final hasInput = loginController.hasInput.value;
            return Container(
              padding: EdgeInsets.only(
                top:
                    hasFocus || hasInput ? AppSize.appSize6 : AppSize.appSize14,
                bottom:
                    hasFocus || hasInput ? AppSize.appSize8 : AppSize.appSize14,
                left: hasFocus ? 0 : AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                border: Border.all(
                  color: hasFocus || hasInput
                      ? AppColor.primaryColor
                      : AppColor.descriptionColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasFocus || hasInput)
                    Padding(
                      padding: EdgeInsets.only(
                        left: hasInput && hasFocus ? AppSize.appSize16 : 0,
                        bottom: AppSize.appSize2,
                      ),
                      child: Text(AppString.phoneNumber,
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor)),
                    ),
                  Row(
                    children: [
                      if (hasFocus || hasInput)
                        Padding(
                          padding: EdgeInsets.only(
                            left: hasInput && hasFocus ? AppSize.appSize16 : 0,
                          ),
                          child: IntrinsicHeight(
                            child: GestureDetector(
                              onTap: () =>
                                  loginCountryPickerBottomSheet(context),
                              child: Row(
                                children: [
                                  Obx(() {
                                    final idx = loginCountryPickerController
                                        .selectedIndex.value;
                                    return Text(
                                      loginCountryPickerController
                                          .countries[idx][AppString.codeText]!,
                                      style: AppStyle.heading4Regular(
                                          color: AppColor.primaryColor),
                                    );
                                  }),
                                  Image.asset(Assets.images.dropdown.path,
                                          width: AppSize.appSize16)
                                      .paddingOnly(
                                          left: AppSize.appSize8,
                                          right: AppSize.appSize3),
                                  const VerticalDivider(
                                      color: AppColor.primaryColor),
                                ],
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SizedBox(
                          height: AppSize.appSize27,
                          child: TextFormField(
                            focusNode: loginController.phoneFocusNode,
                            controller: loginController.mobileController,
                            cursorColor: AppColor.primaryColor,
                            keyboardType: TextInputType.phone,
                            style: AppStyle.heading4Regular(
                                color: AppColor.textColor),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(AppSize.size10)
                            ],
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 0),
                              hintText: AppString.phoneNumber,
                              hintStyle:
                                  TextStyle(color: AppColor.descriptionColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(AppSize.appSize12)),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).paddingOnly(top: AppSize.appSize36),

          // Password field
          Obx(() {
            final hasFocus = loginController.pwFocus.value;
            final hasInput = loginController.passwordController.text.isNotEmpty;
            return Container(
              padding: EdgeInsets.only(
                top:
                    hasFocus || hasInput ? AppSize.appSize6 : AppSize.appSize14,
                bottom:
                    hasFocus || hasInput ? AppSize.appSize8 : AppSize.appSize14,
                left: hasFocus ? 0 : AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                border: Border.all(
                  color: hasFocus || hasInput
                      ? AppColor.primaryColor
                      : AppColor.descriptionColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasFocus || hasInput)
                    Padding(
                      padding: EdgeInsets.only(
                        left: hasInput && hasFocus ? AppSize.appSize16 : 0,
                        bottom: AppSize.appSize2,
                      ),
                      child: Text(AppString.password,
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: AppSize.appSize27,
                          child: TextFormField(
                            focusNode: loginController.pwFocusNode,
                            controller: loginController.passwordController,
                            obscureText: !loginController.showPassword.value,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSize.appSize16,
                                vertical: 0,
                              ),
                              hintText: AppString.password,
                              hintStyle: AppStyle.heading4Regular(
                                color: AppColor.descriptionColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: loginController.togglePassword,
                                child: Icon(
                                  loginController.showPassword.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColor.descriptionColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).paddingOnly(top: AppSize.appSize20),

          // Continue button
          CommonButton(
            onPressed: () => loginController.login(),
            child: Obx(() {
              return loginController.isLoading.value
                  ? SizedBox(
                      width: AppSize.appSize24,
                      height: AppSize.appSize24,
                      child: CircularProgressIndicator(
                          color: AppColor.whiteColor, strokeWidth: 2),
                    )
                  : Text(AppString.continueButton,
                      style:
                          AppStyle.heading5Medium(color: AppColor.whiteColor));
            }),
          ).paddingOnly(top: AppSize.appSize36),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.appSize26),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppString.dontHaveAccount,
              style:
                  AppStyle.heading5Regular(color: AppColor.descriptionColor)),
          GestureDetector(
            onTap: () => Get.offNamed(AppRoutes.registerView),
            child: Text(AppString.registerButton,
                style: AppStyle.heading5Medium(color: AppColor.primaryColor)),
          ),
        ],
      ),
    );
  }
}
