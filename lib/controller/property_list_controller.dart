// lib/controller/property_list_controller.dart

import 'dart:developer';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/controller/search_filter_controller.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyListController extends GetxController {
  final FetchService _fetchService = FetchService();
  final SearchFilterController _searchC = Get.find<SearchFilterController>();

  /// Text field for searching within the results
  final TextEditingController searchController = TextEditingController();

  /// The list of properties loaded from server
  final RxList<PropertyDetail> properties = <PropertyDetail>[].obs;

  /// Loading indicator
  final RxBool isLoading = false.obs;

  /// Track “liked” state per item
  final RxList<bool> isPropertyLiked = <bool>[].obs;

  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => update());
    // Reload when any filter changes
    everAll([
      _searchC.selectCityIndex,
      _searchC.selectAddressIndex,
      _searchC.selectOfferType,
      _searchC.values,
      _searchC.selectPropertyCategory,
      _searchC.selectBedrooms,
      _searchC.selectSide,
      _searchC.selectDetailState,
      _searchC.selectCorner,
      _searchC.selectFurnished,
    ], (_) => loadProperties());

    // Initial fetch
    loadProperties();
  }

  /// Fetch properties with current filters, including favorite state for logged-in user
  /// Fetch properties with current filters, including favorite state for logged-in user
  Future<void> loadProperties({int offset = 0}) async {
    isLoading.value = true;
    try {
      // 1) Build filter parameters
      final cityId = (_searchC.selectCityIndex.value >= 0)
          ? _searchC.citiesList[_searchC.selectCityIndex.value].id
          : 0;
      final address = _searchC.addressList[_searchC.selectAddressIndex.value];
      final offerType = _searchC.offerTypeList.isNotEmpty
          ? _searchC.offerTypeList[_searchC.selectOfferType.value]
          : '';
      final minPrice = _searchC.values.value.start;
      final maxPrice = _searchC.values.value.end;
      final categoryId = (_searchC.selectPropertyCategory.value >= 0)
          ? _searchC
              .propertyCategoryList[_searchC.selectPropertyCategory.value].id
          : 0;
      final bedrooms =
          (_searchC.selectBedrooms.value < _searchC.bedroomsList.length - 1)
              ? _searchC.selectBedrooms.value + 1
              : 0;
      final side = _searchC.sideList[_searchC.selectSide.value];
      final detailState =
          _searchC.detailStateList[_searchC.selectDetailState.value];
      final isCorner = _searchC.cornerList[_searchC.selectCorner.value];
      final furnished = _searchC.furnishedList[_searchC.selectFurnished.value];

      log('Loading properties with filters: '
          'cityId=$cityId, address="$address", offerType="$offerType", '
          'minPrice=$minPrice, maxPrice=$maxPrice, categoryId=$categoryId, '
          'bedrooms=$bedrooms, side="$side", detailState="$detailState", '
          'isCorner="$isCorner", furnished="$furnished"');

      // 2) Read current user ID (0 if not logged in)
      final storage = GetStorage();
      final userMap = storage.read('user') as Map<String, dynamic>?;
      final userId = userMap?['id'] as int? ?? 0;

      // 3) API call (pass userId to fetch favorite flags)
      final list = await _fetchService.getProperties(
        cityId: cityId,
        address: address,
        offerType: offerType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        categoryId: categoryId,
        bedrooms: bedrooms,
        side: side,
        detailState: detailState,
        isCorner: isCorner,
        furnished: furnished,
        userId: userId,
        limit: 20,
        offset: offset,
      );

      // 4) Update reactive lists
      properties.assignAll(list);

      // Seed each property’s liked state from the model
      isPropertyLiked.assignAll(
        list.map((p) => p.isFavorite).toList(),
      );

      log('Loaded ${list.length} properties');
    } catch (e, st) {
      log('Error loading properties: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int index) async {
    if (index < 0 || index >= properties.length) return;

    // 1) Ensure we have a logged-in user
    final storage = GetStorage();
    final userMap = storage.read('user') as Map<String, dynamic>?;
    if (userMap == null) {
      // not logged in → send them to login first
      Get.toNamed(AppRoutes.loginView);
      return;
    }
    final userId = userMap['id'] as int;

    // 2) Optimistically flip UI
    final prop = properties[index];
    final newVal = !isPropertyLiked[index];
    isPropertyLiked[index] = newVal;

    try {
      // 3) Tell server
      final ok = await FetchService.toggleFavorite(
        userId: userId,
        propertyId: prop.id,
        add: newVal,
      );

      // 4) If server rejects, revert
      if (!ok) {
        isPropertyLiked[index] = !newVal;
        Get.snackbar('Error', 'Couldn’t update favorite on server');
      }
    } catch (err) {
      // 5) On network error, revert and notify
      isPropertyLiked[index] = !newVal;
      Get.snackbar('Error', 'Unable to reach server');
    }
  }

  /// Launches the phone dialer with given number
  void launchDialer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
