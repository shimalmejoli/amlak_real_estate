// lib/views/profile/edit_profile_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/common/common_button.dart';
import 'package:amlak_real_estate/common/common_textfield.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/edit_profile_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class EditProfileView extends StatelessWidget {
  final EditProfileController ctrl = Get.put(EditProfileController());

  EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // show loader until the user data is fetched
      if (ctrl.user.value == null) {
        return Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: _buildAppBar(),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: _buildAppBar(),
        body: _buildForm(),
        bottomNavigationBar: _buildButton(context),
      );
    });
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: AppColor.whiteColor,
        scrolledUnderElevation: AppSize.appSize0,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSize.appSize16),
          child: GestureDetector(
            onTap: Get.back,
            child: Image.asset(Assets.images.backArrow.path),
          ),
        ),
        leadingWidth: AppSize.appSize40,
        title: Text(
          AppString.editProfile,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
      );

  Widget _buildForm() => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: AppSize.appSize10,
        ),
        child: Column(
          children: [
            // Avatar + edit icon
            Center(
              child: CircleAvatar(
                radius: AppSize.appSize62,
                backgroundColor: AppColor.whiteColor,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Obx(() {
                      if (ctrl.profileImage.value.isNotEmpty) {
                        return CircleAvatar(
                          radius: AppSize.appSize50,
                          backgroundImage:
                              FileImage(File(ctrl.profileImage.value)),
                        );
                      } else if (ctrl.webImage.value != null) {
                        return CircleAvatar(
                          radius: AppSize.appSize50,
                          backgroundImage: MemoryImage(ctrl.webImage.value!),
                        );
                      } else {
                        return CircleAvatar(
                          radius: AppSize.appSize50,
                          backgroundImage:
                              NetworkImage(ctrl.user.value!.avatarUrl),
                        );
                      }
                    }),
                    Positioned(
                      bottom: AppSize.appSize2,
                      right: AppSize.appSize2,
                      child: GestureDetector(
                        onTap: ctrl.updateProfileImage,
                        child: CircleAvatar(
                          radius: AppSize.appSize15,
                          backgroundColor: AppColor.whiteColor,
                          backgroundImage:
                              AssetImage(Assets.images.editImage.path),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Full Name
            Obx(() => CommonTextField(
                  controller: ctrl.fullNameController,
                  focusNode: ctrl.focusNode,
                  hasFocus: ctrl.hasFullNameFocus.value,
                  hasInput: ctrl.hasFullNameInput.value,
                  hintText: AppString.fullName,
                  labelText: AppString.fullName,
                )).paddingOnly(top: AppSize.appSize16),

            // Role (read-only)
            Padding(
              padding: const EdgeInsets.only(top: AppSize.appSize16),
              child: TextFormField(
                initialValue: ctrl.user.value!.role.capitalizeFirst,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),

            // Phone
            Obx(() {
              final hasFocus = ctrl.hasPhoneNumberFocus.value;
              final hasInput = ctrl.hasPhoneNumberInput.value;
              return Container(
                margin: const EdgeInsets.only(top: AppSize.appSize16),
                padding: EdgeInsets.only(
                  top: hasFocus || hasInput ? 6 : 14,
                  bottom: hasFocus || hasInput ? 8 : 14,
                  left: hasFocus ? 0 : 16,
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
                        padding:
                            EdgeInsets.only(left: hasFocus ? 16 : 0, bottom: 2),
                        child: Text(
                          AppString.phoneNumber,
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor),
                        ),
                      ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            AppString.iraqCode,
                            style: AppStyle.heading4Regular(
                              color: hasFocus
                                  ? AppColor.primaryColor
                                  : AppColor.textColor,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: AppSize.appSize27,
                            child: TextFormField(
                              focusNode: ctrl.phoneNumberFocusNode,
                              controller: ctrl.phoneNumberController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(AppSize.size10)
                              ],
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSize.appSize16, vertical: 0),
                                hintText: AppString.phoneNumber,
                                hintStyle: AppStyle.heading4Regular(
                                    color: AppColor.descriptionColor),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ctrl.phoneError.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4, left: AppSize.appSize16),
                        child: Text(
                          ctrl.phoneError.value,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            }),

            // Email
            Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonTextField(
                      controller: ctrl.emailController,
                      focusNode: ctrl.emailFocusNode,
                      hasFocus: ctrl.hasEmailFocus.value,
                      hasInput: ctrl.hasEmailInput.value,
                      hintText: AppString.emailAddress,
                      labelText: AppString.emailAddress,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (ctrl.emailError.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4, left: AppSize.appSize16),
                        child: Text(
                          ctrl.emailError.value,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                )).paddingOnly(top: AppSize.appSize16),

            // Password
            Obx(() {
              final hasFocus = ctrl.hasPasswordFocus.value;
              final hasInput = ctrl.hasPasswordInput.value;
              return Container(
                margin: const EdgeInsets.only(top: AppSize.appSize16),
                padding: EdgeInsets.only(
                  top: hasFocus || hasInput ? 6 : 14,
                  bottom: hasFocus || hasInput ? 8 : 14,
                  left: hasFocus ? 0 : 16,
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
                        padding:
                            EdgeInsets.only(left: hasFocus ? 16 : 0, bottom: 2),
                        child: Text(
                          AppString.password,
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor),
                        ),
                      ),
                    SizedBox(
                      height: AppSize.appSize27,
                      child: TextFormField(
                        focusNode: ctrl.pwFocusNode,
                        controller: ctrl.passwordController,
                        obscureText: !ctrl.showPassword.value,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize16, vertical: 0),
                          hintText: AppString.password,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: ctrl.toggleShowPassword,
                            child: Icon(
                              ctrl.showPassword.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColor.descriptionColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );

  Widget _buildButton(BuildContext context) => Obx(() => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSize.appSize26,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          top: AppSize.appSize10,
        ),
        child: CommonButton(
          onPressed: ctrl.updateProfile,
          backgroundColor: AppColor.primaryColor,
          child: ctrl.isUpdating.value
              ? SizedBox(
                  width: AppSize.appSize24,
                  height: AppSize.appSize24,
                  child: CircularProgressIndicator(
                      color: AppColor.whiteColor, strokeWidth: 2),
                )
              : Text(
                  AppString.updateProfileButton,
                  style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                ),
        ),
      ));
}
