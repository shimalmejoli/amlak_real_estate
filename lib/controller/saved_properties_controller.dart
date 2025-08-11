// lib/controller/saved_properties_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class SavedPropertiesController extends GetxController {
  final FetchService _fetchService = FetchService();
  final GetStorage _storage = GetStorage();

  // ─── TAB BAR STATE ─────────────────────────────────────────────────
  /// Which tab is selected (0-based index)
  RxInt selectSavedProperty = 0.obs;

  /// Static labels for the tabs
  RxList<String> savedPropertyList = <String>[
    AppString.properties3,
    AppString.project,
    AppString.localities,
  ].obs;

  /// Change selected tab
  void updateSavedProperty(int index) {
    selectSavedProperty.value = index;
  }

  // ─── DYNAMIC SAVED PROPERTIES ────────────────────────────────────────
  /// Loaded from the server for the logged-in user
  final RxList<PropertyDetail> savedProperties = <PropertyDetail>[].obs;

  /// Track “liked” (saved) state per item; all true initially
  final RxList<bool> isPropertyLiked = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedProperties();
  }

  /// Loads the current user's saved properties from the backend
  Future<void> loadSavedProperties() async {
    final userMap = _storage.read('user') as Map<String, dynamic>?;
    final userId = userMap?['id'] as int? ?? 0;

    if (userId == 0) {
      // Not logged in: clear lists
      savedProperties.clear();
      isPropertyLiked.clear();
      return;
    }

    // Fetch from API
    final list = await _fetchService.getSavedProperties(userId: userId);

    // Update reactive lists
    savedProperties.assignAll(list);
    isPropertyLiked.assignAll(List<bool>.filled(list.length, true));
  }

  /// Un-saves a property both on the server and locally
  Future<void> toggleFavorite(int index) async {
    if (index < 0 || index >= savedProperties.length) return;
    final prop = savedProperties[index];

    // Optimistically update UI
    isPropertyLiked[index] = false;

    try {
      // Tell server to remove from favorites
      await FetchService.toggleFavorite(
        userId: _storage.read('user')['id'] as int,
        propertyId: prop.id,
        add: false,
      );
      // Remove locally
      savedProperties.removeAt(index);
      isPropertyLiked.removeAt(index);
    } catch (_) {
      // Revert on error
      isPropertyLiked[index] = true;
      Get.snackbar('Error', 'Couldn’t remove saved property');
    }
  }

  /// Launches the phone dialer with the given number
  Future<void> launchDialer(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
