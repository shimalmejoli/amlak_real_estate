// lib/controller/drawer_controller.dart

import 'package:get/get.dart';
import 'package:amlak_real_estate/configs/app_string.dart';

class SlideDrawerController extends GetxController {
  /// Primary navigation items
  RxList<String> drawerList = [
    AppString.notification,
    AppString.searchProperty,
    AppString.postProperty,
    AppString.editProperty,
    AppString.viewResponses,
  ].obs;

  /// “Your Property Search” section
  RxList<String> drawer2List = [
    AppString.recentActivity,
    AppString.viewedProperties,
    AppString.savedProperties,
    AppString.contactedProperties,
  ].obs;

  /// Badge counts for “Your Property Search”
  RxList<String> searchPropertyNumberList = [
    AppString.number35,
    AppString.number25,
    AppString.number3,
    AppString.number10,
  ].obs;

  /// Third section: Home, Agents, Offices, Interesting Reads
  RxList<String> drawer3List = [
    AppString.homeScreen,
    AppString.agentsList,
    AppString.offices, // ← newly inserted
    AppString.interestingReads,
  ].obs;

  /// Footer links: Terms, Feedback, Rate, Logout
  RxList<String> drawer4List = [
    AppString.termsOfUse,
    AppString.shareFeedback,
    AppString.rateOurApp,
    AppString.logout,
  ].obs;
}
