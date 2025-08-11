// lib/controller/office_list_controller.dart

import 'package:get/get.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/user.dart';

class OfficeListController extends GetxController {
  final FetchService _fetchService = FetchService();

  /// Reactive list of users with role='office'
  final RxList<User> offices = <User>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOffices();
  }

  Future<void> loadOffices() async {
    isLoading.value = true;
    try {
      final list = await _fetchService.getOffices();
      offices.assignAll(list);
    } catch (e) {
      // Optionally handle error, e.g.:
      // Get.snackbar('Error', 'Failed to load offices');
    } finally {
      isLoading.value = false;
    }
  }
}
