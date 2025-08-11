import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class RegisterController extends GetxController {
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;
  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  RxInt selectOption = 0.obs;
  RxBool isChecked = false.obs;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    phoneNumberController.addListener(() {
      hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  void updateOption(int index) {
    selectOption.value = index;
  }

  void toggleCheckbox() {
    isChecked.toggle();
  }

  RxList<String> optionList = [
    AppString.yes,
    AppString.no,
  ].obs;

  @override
  void onClose() {
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
