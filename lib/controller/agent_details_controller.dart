// lib/controller/agent_details_controller.dart

import 'package:get/get.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentDetailsController extends GetxController {
  final FetchService _fetch = FetchService();

  /// The agent’s info
  final Rxn<User> agent = Rxn<User>();

  /// All properties listed by this agent
  final RxList<PropertyDetail> listings = <PropertyDetail>[].obs;

  /// Loading flag
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Expect agent ID passed as Get.arguments
    final id = Get.arguments as int? ?? 0;
    if (id > 0) loadAgentDetails(id);
  }

  Future<void> loadAgentDetails(int id) async {
    try {
      isLoading.value = true;

      // 1) load user
      agent.value = await FetchService.loadUser(id);

      // 2) load this agent’s properties only
      final props = await _fetch.getPropertiesByOwner(
        ownerId: id, // ← use the new by-owner endpoint
        limit: 20,
        offset: 0,
      );
      listings.assignAll(props);
    } catch (e) {
      Get.snackbar('Error', 'Unable to load agent properties');
    } finally {
      isLoading.value = false;
    }
  }

  void launchDialer(String phone) async {
    final normalized = phone.startsWith('0') ? phone.substring(1) : phone;
    final uri = Uri(scheme: 'tel', path: '+964$normalized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}
