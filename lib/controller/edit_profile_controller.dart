// lib/controller/edit_profile_controller.dart

import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/user.dart';

class ApiException implements Exception {
  final String field, message;
  ApiException(this.field, this.message);
}

class EditProfileController extends GetxController {
  final Rxn<User> user = Rxn<User>();

  // Focus & input flags...
  final focusNode = FocusNode();
  final phoneNumberFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final pwFocusNode = FocusNode();

  final hasFullNameFocus = false.obs;
  final hasPhoneNumberFocus = false.obs;
  final hasEmailFocus = false.obs;
  final hasPasswordFocus = false.obs;

  final hasFullNameInput = false.obs;
  final hasPhoneNumberInput = false.obs;
  final hasEmailInput = false.obs;
  final hasPasswordInput = false.obs;

  // Controllers
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Show/hide password
  final showPassword = false.obs;
  void toggleShowPassword() => showPassword.value = !showPassword.value;

  // Inline errors
  final emailError = ''.obs;
  final phoneError = ''.obs;

  // Loading
  final isUpdating = false.obs;

  // Avatar
  final profileImage = ''.obs;
  final webImage = Rx<Uint8List?>(null);

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() => hasFullNameFocus.value = focusNode.hasFocus);
    phoneNumberFocusNode.addListener(
        () => hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus);
    emailFocusNode
        .addListener(() => hasEmailFocus.value = emailFocusNode.hasFocus);
    pwFocusNode
        .addListener(() => hasPasswordFocus.value = pwFocusNode.hasFocus);

    fullNameController.addListener(
        () => hasFullNameInput.value = fullNameController.text.isNotEmpty);
    phoneNumberController.addListener(() =>
        hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty);
    emailController.addListener(
        () => hasEmailInput.value = emailController.text.isNotEmpty);
    passwordController.addListener(
        () => hasPasswordInput.value = passwordController.text.isNotEmpty);

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final arg = Get.arguments;
      final int currentUserId =
          arg is int ? arg : (throw Exception('No user ID passed'));
      final u = await FetchService.loadUser(currentUserId);
      user.value = u;

      fullNameController.text = u.name;
      phoneNumberController.text = u.phone;
      emailController.text = u.email;
      passwordController.text = ''; // leave blank

      hasFullNameInput.value = u.name.isNotEmpty;
      hasPhoneNumberInput.value = u.phone.isNotEmpty;
      hasEmailInput.value = u.email.isNotEmpty;
      hasPasswordInput.value = false;

      if (!kIsWeb && u.rawImageUrl.isNotEmpty) {
        profileImage.value = u.rawImageUrl;
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not load profile');
    }
  }

  Future<void> updateProfile() async {
    emailError.value = '';
    phoneError.value = '';
    final u = user.value!;
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneNumberController.text.trim();
    final pwd = passwordController.text;

    isUpdating.value = true;
    try {
      await FetchService.updateUser(
        id: u.id,
        name: name,
        email: email,
        phone: phone,
        password: pwd.isEmpty ? null : pwd,
      );

      // **Here**: include password in the new User(...)
      final updated = User(
        id: u.id,
        name: name,
        email: email,
        phone: phone,
        password: u.password,
        rawImageUrl: u.rawImageUrl,
        role: u.role,
        // ← add this:
        propertyCount: u.propertyCount,
      );
      user.value = updated;
      // TODO: persist to storage

      Get.back();
      Get.snackbar('Success', 'Profile updated');
    } on ApiException catch (e) {
      if (e.field == 'email') {
        emailError.value = e.message;
      } else if (e.field == 'phone') {
        phoneError.value = e.message;
      } else {
        Get.snackbar('Error', e.message);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> updateProfileImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      if (kIsWeb) {
        webImage.value = await img.readAsBytes();
      } else {
        profileImage.value = img.path;
      }
    }
  }

  @override
  void onClose() {
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    pwFocusNode.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
