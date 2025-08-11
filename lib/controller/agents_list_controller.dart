// lib/controller/agents_list_controller.dart

import 'package:get/get.dart';
import 'package:amlak_real_estate/fetch/fetch.dart';
import 'package:amlak_real_estate/model/user.dart';

class AgentsListController extends GetxController {
  final FetchService _fetchService = FetchService();

  /// Reactive list of users with role='agent'
  final RxList<User> agents = <User>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgents();
  }

  Future<void> loadAgents() async {
    isLoading.value = true;
    try {
      final list = await _fetchService.getAgents();
      agents.assignAll(list);
    } finally {
      isLoading.value = false;
    }
  }
}
