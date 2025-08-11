// lib/controller/office_details_controller.dart

import 'package:get/get.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/model/property_detail.dart';

class OfficeDetailsController extends GetxController {
  /// The office’s info (reusing your User model, with role = 'office')
  final Rxn<User> office = Rxn<User>();

  /// All properties listed by this office
  final RxList<PropertyDetail> listings = <PropertyDetail>[].obs;

  /// Loading flag
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments as int? ?? 0;
    if (id > 0) {
      loadOfficeDetails(id);
    }
  }

  Future<void> loadOfficeDetails(int officeId) async {
    try {
      isLoading.value = true;

      // 1) Load the office record
      office.value = await FetchService.loadUser(officeId);

      // 2) Load this office’s properties using the new method
      final props = await FetchService().getPropertiesByOwner(
        ownerId: officeId, // ← required named parameter
        limit: 20,
        offset: 0,
      );
      listings.assignAll(props);
    } catch (e) {
      Get.snackbar('Error', 'Unable to load office details');
    } finally {
      isLoading.value = false;
    }
  }
}
