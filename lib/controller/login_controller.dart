import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/views/bottom_bar/bottom_bar_view.dart';

class LoginController extends GetxController {
  final FetchService _fetch = FetchService();
  final GetStorage _storage = GetStorage();

  // ─── Phone input ────────────────────────────────────────────────
  final TextEditingController mobileController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final RxBool hasFocus = false.obs;
  final RxBool hasInput = false.obs;

  // ─── Password input ────────────────────────────────────────────
  final TextEditingController passwordController = TextEditingController();
  final FocusNode pwFocusNode = FocusNode();
  final RxBool pwFocus = false.obs;
  final RxBool showPassword = false.obs;

  // ─── Loading & user state ───────────────────────────────────────
  final RxBool isLoading = false.obs;
  final Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();

    // Track phone field focus & input
    phoneFocusNode.addListener(() {
      hasFocus.value = phoneFocusNode.hasFocus;
    });
    mobileController.addListener(() {
      hasInput.value = mobileController.text.isNotEmpty;
    });

    // Track password field focus
    pwFocusNode.addListener(() {
      pwFocus.value = pwFocusNode.hasFocus;
    });

    // If we already have a saved user, load it into memory
    if (_storage.hasData('user')) {
      final m = _storage.read<Map>('user')!;
      user.value = User(
        id: m['id'] as int,
        name: m['name'] as String,
        email: m['email'] as String,
        phone: m['phone'] as String,
        password: m['password'] as String, // ← was missing
        rawImageUrl: m['image_url'] as String,
        role: m['role'] as String, // ← cast to String
        propertyCount: (m['property_count'] as num?)?.toInt() ?? 0,
      );
    }
  }

  /// Toggle password visibility
  void togglePassword() {
    showPassword.value = !showPassword.value;
  }

  /// Perform login, persist user, then navigate
  Future<void> login() async {
    final phone = mobileController.text.trim();
    final pass = passwordController.text;

    if (phone.isEmpty || pass.isEmpty) {
      Get.snackbar('Error', 'Phone and password cannot be empty');
      return;
    }

    isLoading.value = true;
    try {
      final u = await _fetch.loginUser(phone: phone, password: pass);
      if (u == null) throw Exception('Invalid credentials');

      user.value = u;

      // Persist user data locally
      _storage.write('user', {
        'id': u.id,
        'name': u.name,
        'email': u.email,
        'phone': u.phone,
        'image_url': u.rawImageUrl,
        'role': u.role, // ← persist it
      });

      // Navigate into the app
      Get.offAll(() => const BottomBarView());
    } on Exception catch (e, st) {
      debugPrint('❌ Login exception: $e');
      debugPrintStack(label: 'Stack trace:', stackTrace: st);
      Get.snackbar('Login failed', e.toString());
    } catch (e, st) {
      debugPrint('❌ Unexpected error: $e');
      debugPrintStack(label: 'Stack trace:', stackTrace: st);
      Get.snackbar('Login error', 'An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneFocusNode.dispose();
    mobileController.dispose();
    pwFocusNode.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
