import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class EditPropertyController extends GetxController {
  RxList<String> editPropertyTitleList = [
    AppString.basicDetails,
    AppString.propertyDetails,
    AppString.priceDetails,
    AppString.amenities,
  ].obs;

  RxList<String> editPropertySubtitleList = [
    AppString.basicDetailsString,
    AppString.propertyDetailsString,
    AppString.priceDetailsString,
    AppString.amenitiesString,
  ].obs;
}
