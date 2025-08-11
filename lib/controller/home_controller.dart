// lib/controller/home_controller.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/model/PropertyCategory.dart';
import 'package:amlak_real_estate/model/city.dart';
import 'package:amlak_real_estate/model/trending_property.dart';
import 'package:amlak_real_estate/model/project.dart';
import 'package:amlak_real_estate/model/project_image.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/fetch/project_service.dart';

class HomeController extends GetxController {
  // ─── CONTROLLERS & STATE ─────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  final RxInt selectProperty = 0.obs;
  final RxInt selectCountry = 0.obs;
  final RxList<bool> isTrendPropertyLiked = <bool>[].obs;

  // ─── DYNAMIC LISTS FROM SERVER ───────────────────────────────────────
  final RxList<PropertyCategory> propertyOptionList = <PropertyCategory>[].obs;
  final RxList<City> popularCities = <City>[].obs;
  final RxList<TrendingProperty> trendingList = <TrendingProperty>[].obs;

  // ─── Recommended Projects (NEW) ─────────────────────────────────────
  final RxList<Project> recommendedProjects = <Project>[].obs;
  final RxBool projectsLoading = true.obs;

  // ─── City‐tabs (NEW) ─────────────────────────────────────────────────
  final RxList<City> cities = <City>[].obs;
  final RxInt selectedCityIndex = 0.obs;

  // ─── STATIC LISTS FOR OTHER SECTIONS ────────────────────────────────
  final RxList<String> countryOptionList = [
    AppString.westernMumbai,
    AppString.switzerland,
    AppString.nepal,
    AppString.exploreNew,
  ].obs;

  // Your Listing static data
  final RxList<String> projectImageList = [
    Assets.images.project1.path,
    Assets.images.project2.path,
    Assets.images.project1.path,
  ].obs;
  final RxList<String> projectPriceList = [
    AppString.rupees4Cr,
    AppString.priceOnRequest,
    AppString.priceOnRequest,
  ].obs;
  final RxList<String> projectTitleList = [
    AppString.residentialApart,
    AppString.residentialApart2,
    AppString.plot2000ft,
  ].obs;
  final RxList<String> projectAddressList = [
    AppString.address1,
    AppString.address2,
    AppString.address3,
  ].obs;
  final RxList<String> projectTimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.month2Ago,
  ].obs;

  final RxList<String> project2ImageList = [
    Assets.images.project3.path,
    Assets.images.project4.path,
    Assets.images.project3.path,
  ].obs;
  final RxList<String> project2PriceList = [
    AppString.rupees2Cr,
    AppString.rupees5Cr,
    AppString.rupees2Cr,
  ].obs;
  final RxList<String> project2TitleList = [
    AppString.residentialApart,
    AppString.plot2000ft,
    AppString.residentialApart,
  ].obs;
  final RxList<String> project2AddressList = [
    AppString.address4,
    AppString.address5,
    AppString.address4,
  ].obs;
  final RxList<String> project2TimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.days2Ago,
  ].obs;

  // Recent responses static data (unused now)
  final RxList<String> responseImageList = [
    Assets.images.response1.path,
    Assets.images.response2.path,
    Assets.images.response3.path,
    Assets.images.response4.path,
  ].obs;
  final RxList<String> responseNameList = [
    AppString.rudraProperties,
    AppString.claudeAnderson,
    AppString.rohitBhati,
    AppString.heerKher,
  ].obs;
  final RxList<String> responseTimingList = [
    AppString.today,
    AppString.today,
    AppString.yesterday,
    AppString.days4Ago,
  ].obs;
  final RxList<String> responseEmailList = [
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.heerEmail,
  ].obs;

  // Search trends static data
  final RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.searchProperty2.path,
  ].obs;
  final RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.modernHouse,
  ].obs;
  final RxList<String> searchAddressList = [
    AppString.address6,
    AppString.address7,
  ].obs;
  final RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.rupees22Lakh,
  ].obs;
  final RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;
  final RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.sq456,
  ].obs;

  // Popular builders static data
  final RxList<String> popularBuilderImageList = [
    Assets.images.builder1.path,
    Assets.images.builder2.path,
    Assets.images.builder3.path,
    Assets.images.builder4.path,
    Assets.images.builder5.path,
    Assets.images.builder6.path,
  ].obs;
  final RxList<String> popularBuilderTitleList = [
    AppString.sobhaDevelopers,
    AppString.kalpataru,
    AppString.godrej,
    AppString.unitech,
    AppString.casagrand,
    AppString.brigade,
  ].obs;

  // Upcoming projects static data
  final RxList<String> upcomingProjectImageList = [
    Assets.images.upcomingProject1.path,
    Assets.images.upcomingProject2.path,
    Assets.images.upcomingProject3.path,
  ].obs;
  final RxList<String> upcomingProjectTitleList = [
    AppString.luxuryVilla,
    AppString.shreenathjiResidency,
    AppString.pramukhDevelopersSurat,
  ].obs;
  final RxList<String> upcomingProjectAddressList = [
    AppString.address8,
    AppString.address9,
    AppString.address10,
  ].obs;
  final RxList<String> upcomingProjectFlatSizeList = [
    AppString.bhk3Apartment,
    AppString.bhk4Apartment,
    AppString.bhk5Apartment,
  ].obs;
  final RxList<String> upcomingProjectPriceList = [
    AppString.lakh45,
    AppString.lakh85,
    AppString.lakh85,
  ].obs;

  // ─── LOCAL CACHE ─────────────────────────────────────────────────────
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();

    // Initialize trending “liked” toggles
    isTrendPropertyLiked.assignAll(
      List<bool>.filled(searchImageList.length, false),
    );

    // 1) Load property categories
    _loadPropertyCategories();

    // 2) Load popular cities
    _loadPopularCities();

    // 3) Load trending properties
    _loadTrendingProperties();

    // 4) Load cities for tabs
    _loadCities();

    // 5) Load recommended projects
    _loadRecommendedProjects();
  }

  /// Fetch & cache property categories
  Future<void> _loadPropertyCategories() async {
    final fresh = await FetchService.loadPropertyCategories();
    if (fresh.isNotEmpty) {
      propertyOptionList.assignAll([
        PropertyCategory(id: 0, name: 'All', imageUrl: ''),
        ...fresh,
      ]);
      _storage.write(
        'property_categories',
        fresh.map((c) => c.toJson()).toList(),
      );
    }
  }

  /// Fetch & cache popular cities
  Future<void> _loadPopularCities() async {
    final fresh = await FetchService.loadPopularCities();
    if (fresh.isNotEmpty) {
      popularCities.assignAll(fresh);
      _storage.write(
        'popular_cities',
        fresh.map((c) => c.toJson()).toList(),
      );
      for (final city in fresh) {
        DefaultCacheManager().getSingleFile(city.imageUrl);
      }
    }
  }

  /// Fetch trending properties
  Future<void> _loadTrendingProperties() async {
    final fresh = await FetchService.loadTrendingProperties();
    if (fresh.isNotEmpty) {
      trendingList.assignAll(fresh);
      for (final prop in fresh) {
        DefaultCacheManager().getSingleFile(prop.imageUrl);
      }
    }
  }

  /// Fetch all cities for city‐tabs
  Future<void> _loadCities() async {
    try {
      // reuse the same endpoint you already have for popularCities
      final fresh = await FetchService.loadPopularCities();
      if (fresh.isNotEmpty) {
        cities.assignAll(fresh);
      }
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }
  }

  /// Fetch recommended projects & prefetch images
  Future<void> _loadRecommendedProjects() async {
    projectsLoading.value = true;
    try {
      final list = await ProjectService.loadRecommendedProjects(limit: 5);
      recommendedProjects.assignAll(list);
      for (final p in recommendedProjects) {
        final url = p.imageUrl;
        if (url != null && url.isNotEmpty) {
          CachedNetworkImageProvider(url).resolve(const ImageConfiguration());
        }
      }
    } catch (e) {
      debugPrint('Error loading recommended projects: $e');
    } finally {
      projectsLoading.value = false;
    }
  }

  /// Update selected property category
  void updateProperty(int index) {
    selectProperty.value = index;
  }

  /// Update selected country filter
  void updateCountry(int index) {
    selectCountry.value = index;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
