// lib/controller/property_details_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class PropertyDetailsController extends GetxController {
  // ─── DYNAMIC DATA ───────────────────────────────────────────────────
  final Rx<PropertyDetail?> detail = Rx<PropertyDetail?>(null);

  // ─── FAVORITE STATE ─────────────────────────────────────────────────
  final RxBool isFavorite = false.obs;
  final GetStorage storage = GetStorage();

  // ─── IMAGE CAROUSEL STATE ───────────────────────────────────────────
  final PageController imagePageController = PageController();
  final RxInt currentImagePage = 0.obs;

  // ─── “SIMILAR HOMES” LIKE STATE ─────────────────────────────────────
  final RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  // ─── DESCRIPTION TRUNCATION ─────────────────────────────────────────
  /// Word limit for the collapsed description
  static const int aboutWordLimit = 60;

  /// Whether we’re showing the full description
  final RxBool isDescriptionExpanded = false.obs;

  /// Toggle between collapsed and full text
  void toggleDescription() => isDescriptionExpanded.toggle();

  /// Provides either the first [aboutWordLimit] words + “…” or the full text
  String get displayedDescription {
    final desc = detail.value?.description ?? '';
    final words = desc.split(RegExp(r'\s+'));
    if (words.length <= aboutWordLimit || isDescriptionExpanded.value) {
      return desc;
    }
    return words.take(aboutWordLimit).join(' ') + '…';
  }

  // ─── UI STATE ───────────────────────────────────────────────────────
  RxInt selectAgent = 0.obs;
  RxBool isChecked = false.obs;
  RxInt selectProperty = 0.obs;
  RxBool isVisitExpanded = false.obs;

  // ─── FORM CONTROLLERS & FOCUS ──────────────────────────────────────
  final FocusNode focusNode = FocusNode();
  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;

  // ─── SCROLL STATE ───────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  // ─── STATIC DATA FOR OTHER SECTIONS ────────────────────────────────
  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;
  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.bhk2,
  ].obs;
  RxList<String> searchProperty2ImageList = [
    Assets.images.plot.path,
    Assets.images.indianRupee.path,
  ].obs;
  RxList<String> searchProperty2TitleList = [
    AppString.squareFeet966,
    AppString.rupee3252,
  ].obs;
  RxList<String> keyHighlightsTitleList = [
    AppString.parkingAvailable,
    AppString.poojaRoomAvailable,
    AppString.semiFurnishedText,
    AppString.balconies1,
  ].obs;
  RxList<String> propertyDetailsTitleList = [
    AppString.layout,
    AppString.ownerShip,
    AppString.superArea,
    AppString.overlooking,
    AppString.widthOfFacingRoad,
    AppString.flooring,
    AppString.waterSource,
    AppString.furnishing,
    AppString.facing,
    AppString.propertyId,
  ].obs;
  RxList<String> propertyDetailsSubTitleList = [
    AppString.bhk3PoojaRoom,
    AppString.freehold,
    AppString.square785,
    AppString.parkMainRoad,
    AppString.feet60,
    AppString.vitrified,
    AppString.municipalCorporation,
    AppString.semiFurnished,
    AppString.west,
    AppString.propertyIdNumber,
  ].obs;
  RxList<String> furnishingDetailsImageList = [
    Assets.images.wardrobe.path,
    Assets.images.bedSheet.path,
    Assets.images.stove.path,
    Assets.images.waterPurifier.path,
    Assets.images.fan.path,
    Assets.images.lights.path,
  ].obs;
  RxList<String> furnishingDetailsTitleList = [
    AppString.wardrobe,
    AppString.sofa,
    AppString.stove,
    AppString.waterPurifier,
    AppString.fan,
    AppString.lights,
  ].obs;
  RxList<String> facilitiesImageList = [
    Assets.images.privateGarden.path,
    Assets.images.reservedParking.path,
    Assets.images.rainWater.path,
  ].obs;
  RxList<String> facilitiesTitleList = [
    AppString.privateGarden,
    AppString.reservedParking,
    AppString.rainWaterHarvesting,
  ].obs;
  RxList<String> dayList = [
    AppString.mondayText,
    AppString.tuesdayText,
    AppString.wednesdayText,
    AppString.thursdayText,
    AppString.fridayText,
    AppString.saturdayText,
    AppString.sundayText,
  ].obs;
  RxList<String> timingList = List<String>.filled(7, AppString.timing1012).obs
    ..[6] = AppString.close;
  RxList<String> realEstateList = [
    AppString.yes,
    AppString.no,
  ].obs;
  RxList<String> reviewDateList = [
    AppString.november13,
    AppString.december13,
    AppString.may22,
  ].obs;
  RxList<String> reviewRatingImageList = [
    Assets.images.rating4.path,
    Assets.images.rating3.path,
    Assets.images.rating5.path,
  ].obs;
  RxList<String> reviewProfileList = [
    Assets.images.dh.path,
    Assets.images.da.path,
    Assets.images.mm.path,
  ].obs;
  RxList<String> reviewProfileNameList = [
    AppString.dorothyHowe,
    AppString.douglasAnderson,
    AppString.mamieMonahan,
  ].obs;
  RxList<String> reviewTypeList = [
    AppString.buyer,
    AppString.seller,
    AppString.seller,
  ].obs;
  RxList<String> reviewDescriptionList = [
    AppString.dorothyHoweString,
    AppString.douglasAndersonString,
    AppString.mamieMonahanString,
  ].obs;
  RxList<String> searchImageList = [
    Assets.images.alexaneFranecki.path,
    Assets.images.searchProperty5.path,
  ].obs;
  RxList<String> searchTitleList = [
    AppString.alexane,
    AppString.happinessChasers,
  ].obs;
  RxList<String> searchAddressList = [
    AppString.baumbachLakes,
    AppString.wildermanAddress,
  ].obs;
  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.crore1,
  ].obs;
  RxList<String> searchRatingList = [
    AppString.rating4Point5,
    AppString.rating4Point2,
  ].obs;
  RxList<String> similarPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.squareMeter256,
  ].obs;
  RxList<String> interestingImageList = [
    Assets.images.read1.path,
    Assets.images.read2.path,
  ].obs;
  RxList<String> interestingTitleList = [
    AppString.readString1,
    AppString.readString2,
  ].obs;
  RxList<String> interestingDateList = [
    AppString.november23,
    AppString.october16,
  ].obs;
  RxList<String> propertyList = [
    AppString.overview,
    AppString.highlights,
    AppString.propertyDetails,
    AppString.about,
    AppString.facilities,
    AppString.owner,
  ].obs;

  @override
  void onInit() {
    super.onInit();

    // 1) Parse passed property ID and load detail + favorite
    final arg = Get.arguments;
    final propertyId =
        (arg is int) ? arg : int.tryParse(arg?.toString() ?? '') ?? 0;
    if (propertyId > 0) {
      _loadDetail(propertyId);
      _loadFavorite(propertyId);
    }

    // 2) Initialize “Similar Homes” liked state
    isSimilarPropertyLiked.assignAll(
      List<bool>.filled(searchImageList.length, false),
    );

    // 3) Wire up focus/input listeners
    focusNode.addListener(() => hasFullNameFocus.value = focusNode.hasFocus);
    phoneNumberFocusNode.addListener(
      () => hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus,
    );
    emailFocusNode.addListener(
      () => hasEmailFocus.value = emailFocusNode.hasFocus,
    );
    fullNameController.addListener(
      () => hasFullNameInput.value = fullNameController.text.isNotEmpty,
    );
    mobileNumberController.addListener(
      () => hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty,
    );
    emailController.addListener(
      () => hasEmailInput.value = emailController.text.isNotEmpty,
    );

    // 4) Track carousel page changes
    imagePageController.addListener(() {
      currentImagePage.value = imagePageController.page?.round() ?? 0;
    });
  }

  /// Fetch detail from API
  Future<void> _loadDetail(int id) async {
    final loaded = await FetchService.loadPropertyDetail(id);
    if (loaded != null) {
      detail.value = loaded;
    }
  }

  /// Check initial favorite state
  Future<void> _loadFavorite(int propertyId) async {
    try {
      final user = storage.read('user') as Map<String, dynamic>;
      final userId = user['id'] as int;
      isFavorite.value = await FetchService.checkFavorite(
        userId: userId,
        propertyId: propertyId,
      );
    } catch (_) {
      isFavorite.value = false;
    }
  }

  /// Toggle favorite on server & in-memory
  Future<void> toggleFavorite() async {
    if (detail.value == null) return;

    final user = storage.read('user') as Map<String, dynamic>;
    final userId = user['id'] as int;
    final propertyId = detail.value!.id;
    final newVal = !isFavorite.value;
    isFavorite.value = newVal;

    try {
      final ok = await FetchService.toggleFavorite(
        userId: userId,
        propertyId: propertyId,
        add: newVal,
      );
      if (!ok) {
        isFavorite.value = !newVal;
        Get.snackbar('Error', 'Couldn’t update favorites on server');
      }
    } catch (err) {
      isFavorite.value = !newVal;
      Get.snackbar('Error', 'Unable to reach server');
    }
  }

  // ─── OTHER UI ACTIONS ───────────────────────────────────────────────
  void updateAgent(int idx) => selectAgent.value = idx;
  void toggleCheckbox() => isChecked.toggle();
  void updateProperty(int idx) {
    selectProperty.value = idx;
    // your scroll‐offset logic…
  }

  void toggleVisitExpansion() => isVisitExpanded.toggle();

  @override
  void onClose() {
    imagePageController.dispose();
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
