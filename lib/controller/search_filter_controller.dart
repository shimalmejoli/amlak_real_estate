// lib/controller/search_filter_controller.dart
import 'dart:convert';
import 'package:amlak_real_estate/Fetch/fetch.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/model/PropertyCategory.dart';
import 'package:amlak_real_estate/model/city.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum SearchContentType { searchFilter, search }

class SearchFilterController extends GetxController {
  final FetchService _fetchService = FetchService();

  // UI state
  final TextEditingController searchController = TextEditingController();
  final Rx<SearchContentType> contentType = SearchContentType.searchFilter.obs;

  // Selection indices
  final RxInt selectProperty = 0.obs;
  final RxInt selectOfferType = 0.obs;
  final RxInt selectBedrooms = 0.obs;
  final RxInt selectPropertyCategory = 0.obs;
  final RxInt selectCityIndex = (-1).obs;
  final RxInt selectAddressIndex = 0.obs;
  final RxInt selectSide = 0.obs;
  final RxInt selectDetailState = 0.obs;
  final RxInt selectCorner = 0.obs;
  final RxInt selectFurnished = 0.obs;

  // Dynamic lists
  final RxList<PropertyCategory> propertyCategoryList =
      <PropertyCategory>[].obs;
  final RxBool categoriesLoading = true.obs;

  final RxList<City> citiesList = <City>[].obs;
  final RxBool citiesLoading = true.obs;

  final RxList<String> addressList = <String>['All'].obs;
  final RxBool addressesLoading = false.obs;

  // Budget slider
  final RxDouble maxBudget = 1000000.0.obs;
  final Rx<RangeValues> values = const RangeValues(100, 1000000).obs;

  // Static lists
  final RxList<String> propertyList =
      [AppString.residential, AppString.commercial].obs;
  final RxList<String> offerTypeList = <String>[].obs;
  final RxList<String> bedroomsList = ['+1', '+2', '+3', '+4', '+more'].obs;
  final RxList<String> sideList = [
    'All',
    'North',
    'South',
    'East',
    'West',
    'North-East',
    'North-West',
    'South-East',
    'South-West'
  ].obs;
  final RxList<String> detailStateList = ['All', 'new', 'used', 'ground'].obs;
  final RxList<String> cornerList = ['All', 'Corner', 'Not Corner'].obs;
  final RxList<String> furnishedList = ['All', 'Furnished', 'Unfurnished'].obs;

  // Count
  final RxInt totalCount = 0.obs;

  // Currency formatter
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: r'$ ', decimalDigits: 0);
  String get startValueText => _currencyFormat.format(values.value.start);
  String get endValueText => _currencyFormat.format(values.value.end);

  @override
  void onInit() {
    super.onInit();
    // load everything in parallel
    Future.wait([
      _loadOfferTypes(),
      _loadPropertyCategories(),
      _loadMaxBudget(),
      _loadCities(),
    ]).then((_) => _loadPropertyCount());

    // re-fetch count when any filter changes
    everAll([
      selectCityIndex,
      selectAddressIndex,
      selectOfferType,
      values,
      selectPropertyCategory,
      selectBedrooms,
      selectSide,
      selectDetailState,
      selectCorner,
      selectFurnished,
    ], (_) => _loadPropertyCount());
  }

  Future<void> _loadOfferTypes() async {
    try {
      final opts = await _fetchService.getOfferTypes();
      offerTypeList.assignAll(opts.isNotEmpty
          ? opts
          : [AppString.buy, AppString.rentPg, AppString.room]);
    } catch (_) {
      offerTypeList
          .assignAll([AppString.buy, AppString.rentPg, AppString.room]);
    }
  }

  Future<void> _loadPropertyCategories() async {
    categoriesLoading.value = true;
    try {
      final cats = await FetchService.loadPropertyCategories();
      propertyCategoryList.assignAll(cats);
    } finally {
      categoriesLoading.value = false;
    }
  }

  Future<void> _loadMaxBudget() async {
    try {
      final fetchedMax = await _fetchService.getMaxPrice();
      maxBudget.value = fetchedMax;
      final start = values.value.start;
      values.value =
          RangeValues(start < fetchedMax ? start : fetchedMax, fetchedMax);
    } catch (_) {}
  }

  Future<void> _loadCities() async {
    citiesLoading.value = true;
    try {
      final list = await FetchService.loadPopularCities();
      citiesList.assignAll(list);
    } finally {
      citiesLoading.value = false;
    }
  }

  Future<void> _loadAddresses(int cityId) async {
    addressesLoading.value = true;
    try {
      final addrs = await FetchService.loadAddresses(cityId);
      addressList
        ..clear()
        ..add('All')
        ..addAll(addrs);
      selectAddressIndex.value = 0;
    } finally {
      addressesLoading.value = false;
    }
  }

  Future<void> _loadPropertyCount() async {
    final cityId =
        selectCityIndex.value >= 0 ? citiesList[selectCityIndex.value].id : 0;
    final address = addressList[selectAddressIndex.value];
    final offerType =
        offerTypeList.isNotEmpty ? offerTypeList[selectOfferType.value] : '';
    final minPrice = values.value.start;
    final maxPrice = values.value.end;
    final categoryId = selectPropertyCategory.value >= 0
        ? propertyCategoryList[selectPropertyCategory.value].id
        : 0;
    final bedrooms = selectBedrooms.value < bedroomsList.length - 1
        ? selectBedrooms.value + 1
        : 0;
    final side = sideList[selectSide.value];
    final detailState = detailStateList[selectDetailState.value];
    final isCorner = cornerList[selectCorner.value];
    final furnished = furnishedList[selectFurnished.value];

    try {
      final cnt = await _fetchService.getPropertyCount(
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
      );
      totalCount.value = cnt;
    } catch (_) {
      totalCount.value = 0;
    }
  }

  // selection methods
  void updateProperty(int idx) => selectProperty.value = idx;
  void updateOfferType(int idx) => selectOfferType.value = idx;
  void updateBedrooms(int idx) => selectBedrooms.value = idx;
  void updatePropertyCategory(int idx) => selectPropertyCategory.value = idx;
  void selectCity(int idx) {
    selectCityIndex.value = idx;
    final city = citiesList[idx];
    searchController.text = city.name;
    _loadAddresses(city.id);
  }

  void selectAddress(int idx) {
    selectAddressIndex.value = idx;
    final city = citiesList[selectCityIndex.value];
    final addr = addressList[idx];
    searchController.text = addr == 'All' ? city.name : '${city.name}, $addr';
  }

  void updateSide(int idx) => selectSide.value = idx;
  void updateDetailState(int idx) => selectDetailState.value = idx;
  void updateCorner(int idx) => selectCorner.value = idx;
  void updateFurnished(int idx) => selectFurnished.value = idx;
  void updateValues(RangeValues v) => values.value = v;
  void setContent(SearchContentType t) => contentType.value = t;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
