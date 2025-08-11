import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class PostPropertyController extends GetxController {
  RxBool hasFocus = false.obs;
  RxBool hasInput = false.obs;
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectCategories = 0.obs;
  RxInt selectPropertyType = 0.obs;
  FocusNode focusNode = FocusNode();
  TextEditingController mobileController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      hasFocus.value = focusNode.hasFocus;
    });
    mobileController.addListener(() {
      hasInput.value = mobileController.text.isNotEmpty;
    });
  }

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
  }

  void updateCategories(int index) {
    selectCategories.value = index;
  }

  void updateSelectProperty(int index) {
    selectPropertyType.value = index;
  }

  RxList<String> propertyLookingList = [
    AppString.buy,
    AppString.rent,
    AppString.pg,
  ].obs;

  RxList<String> categoriesList = [
    AppString.residential,
    AppString.commercial,
  ].obs;

  RxList<String> propertyTypeList = [
    AppString.flatApartment,
    AppString.independentHouse,
    AppString.builderFloor,
    AppString.residentialPlot,
    AppString.plotLand,
    AppString.officeSpace,
    AppString.other,
  ].obs;

  RxList<String> propertyTypeImageList = [
    Assets.images.flatApartment.path,
    Assets.images.independentHouse.path,
    Assets.images.builderFloor.path,
    Assets.images.builderFloor.path,
    Assets.images.plotLand.path,
    Assets.images.officeSpace.path,
    Assets.images.other.path,
  ].obs;

  @override
  void onClose() {
    focusNode.dispose();
    mobileController.dispose();
    super.onClose();
  }
}
