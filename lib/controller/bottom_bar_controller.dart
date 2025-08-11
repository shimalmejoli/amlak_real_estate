import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class BottomBarController extends GetxController {
  RxInt selectIndex = 0.obs;
  late PageController pageController;

  BottomBarController({int initialIndex = 0}) {
    selectIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  void updateIndex(int index) {
    selectIndex.value = index;
    pageController.jumpToPage(index);
  }

  RxList<String> bottomBarImageList = [
    Assets.images.home.path,
    Assets.images.task.path,
    '',
    Assets.images.save.path,
    Assets.images.user.path,
  ].obs;

  RxList<String> bottomBarMenuNameList = [
    AppString.home,
    AppString.activity,
    '',
    AppString.saved,
    AppString.profile,
  ].obs;
}
