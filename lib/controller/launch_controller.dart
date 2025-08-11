import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LaunchController extends GetxController {
  final _storage = GetStorage();
  final isFirstLaunch = true.obs;

  @override
  void onInit() {
    super.onInit();
    bool hasLaunched = _storage.read('hasLaunchedBefore') ?? false;
    if (hasLaunched) {
      isFirstLaunch.value = false;
    } else {
      _storage.write('hasLaunchedBefore', true);
      isFirstLaunch.value = true;
    }
  }
}
