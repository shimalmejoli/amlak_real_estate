// lib/views/search_filter_form.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/controller/search_filter_controller.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class SearchFilterForm extends StatelessWidget {
  const SearchFilterForm({Key? key}) : super(key: key);

  SearchFilterController get c => Get.find<SearchFilterController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // The filter content
            Expanded(child: _FilterContent()),

            // See Results button
            Padding(
              padding: const EdgeInsets.all(AppSize.appSize16),
              child: SizedBox(
                width: double.infinity,
                height: AppSize.appSize48,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.propertyListView);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                  ),
                  child: Obx(() {
                    final cnt = c.totalCount.value;
                    return Text(
                      'See All $cnt ${cnt == 1 ? "Property" : "Properties"}',
                      style:
                          AppStyle.heading5Medium(color: AppColor.whiteColor),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<SearchFilterController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Property vs. Commercial toggle
        Row(
          children: List.generate(c.propertyList.length, (i) {
            return Expanded(
              child: GestureDetector(
                onTap: () => c.updateProperty(i),
                child: Obx(() {
                  final selected = c.selectProperty.value == i;
                  return Container(
                    height: AppSize.appSize25,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize14),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                        right: BorderSide(
                          color: i == c.propertyList.length - 1
                              ? Colors.transparent
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        c.propertyList[i],
                        style: AppStyle.heading5Medium(
                          color: selected
                              ? AppColor.primaryColor
                              : AppColor.textColor,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // ─── Filters list
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSize.appSize20),
            children: [
              // City search field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  color: AppColor.whiteColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: AppSize.appSizePoint1,
                      blurRadius: AppSize.appSize2,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: c.searchController,
                  cursorColor: AppColor.primaryColor,
                  style: AppStyle.heading4Regular(color: AppColor.textColor),
                  readOnly: true,
                  onTap: () => c.setContent(SearchContentType.search),
                  decoration: InputDecoration(
                    hintText: AppString.searchCity,
                    hintStyle: AppStyle.heading4Regular(
                        color: AppColor.descriptionColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16),
                      child: Image.asset(Assets.images.search.path),
                    ),
                    prefixIconConstraints: const BoxConstraints(maxWidth: 51),
                  ),
                ),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),

              // “Looking To”
              Text(
                AppString.lookingTo,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                if (c.offerTypeList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Row(
                  children: List.generate(c.offerTypeList.length, (i) {
                    final selected = c.selectOfferType.value == i;
                    return GestureDetector(
                      onTap: () => c.updateOfferType(i),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSize.appSize16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize16,
                            vertical: AppSize.appSize10),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Text(
                          c.offerTypeList[i],
                          style: AppStyle.heading5Medium(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.descriptionColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                );
              }),

              // Budget slider
              Text(
                AppString.budget,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                return Column(
                  children: [
                    RangeSlider(
                      values: c.values.value,
                      min: 100,
                      max: c.maxBudget.value,
                      divisions:
                          ((c.maxBudget.value - 100) ~/ 100).clamp(1, 1000),
                      onChanged: c.updateValues,
                      activeColor: AppColor.primaryColor,
                      inactiveColor: AppColor.secondaryColor,
                    ).paddingOnly(
                      left: AppSize.appSize16,
                      right: AppSize.appSize16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: AppSize.appSize37,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                border: Border.all(
                                    color: AppColor.descriptionColor,
                                    width: AppSize.appSizePoint7),
                              ),
                              child: Center(
                                child: Text(
                                  c.startValueText,
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            AppString.toText,
                            style: AppStyle.heading5Medium(
                                color: AppColor.textColor),
                          ).paddingSymmetric(horizontal: AppSize.appSize26),
                          Expanded(
                            child: Container(
                              height: AppSize.appSize37,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                border: Border.all(
                                    color: AppColor.descriptionColor,
                                    width: AppSize.appSizePoint7),
                              ),
                              child: Center(
                                child: Text(
                                  c.endValueText,
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              // Types of Property
              Text(
                AppString.typesOfProperty,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                if (c.categoriesLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (c.propertyCategoryList.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Wrap(
                  spacing: AppSize.appSize16,
                  runSpacing: AppSize.appSize12,
                  children: List.generate(c.propertyCategoryList.length, (i) {
                    final cat = c.propertyCategoryList[i];
                    final selected = c.selectPropertyCategory.value == i;
                    return GestureDetector(
                      onTap: () => c.updatePropertyCategory(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize16,
                            vertical: AppSize.appSize10),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Text(
                          cat.name,
                          style: AppStyle.heading5Medium(
                              color: selected
                                  ? AppColor.primaryColor
                                  : AppColor.descriptionColor),
                        ),
                      ),
                    );
                  }),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                );
              }),

              // Number of Bedrooms
              Text(
                AppString.noOfBedrooms,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                child: Row(
                  children: List.generate(c.bedroomsList.length, (i) {
                    final selected = c.selectBedrooms.value == i;
                    return GestureDetector(
                      onTap: () => c.updateBedrooms(i),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSize.appSize16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize16,
                            vertical: AppSize.appSize10),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            c.bedroomsList[i],
                            style: AppStyle.heading5Medium(
                              color: selected
                                  ? AppColor.primaryColor
                                  : AppColor.descriptionColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ).paddingOnly(top: AppSize.appSize16),

              // Side
              Text(
                'Side',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                return Wrap(
                  spacing: AppSize.appSize12,
                  runSpacing: AppSize.appSize12,
                  children: List.generate(c.sideList.length, (i) {
                    final selected = c.selectSide.value == i;
                    return GestureDetector(
                      onTap: () => c.updateSide(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize14,
                            vertical: AppSize.appSize8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColor.primaryColor.withOpacity(.1)
                              : AppColor.whiteColor,
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Text(
                          c.sideList[i],
                          style: AppStyle.heading5Medium(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.textColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                );
              }),

              // Property State
              Text(
                'Property State',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                return Wrap(
                  spacing: AppSize.appSize12,
                  runSpacing: AppSize.appSize12,
                  children: List.generate(c.detailStateList.length, (i) {
                    final selected = c.selectDetailState.value == i;
                    return GestureDetector(
                      onTap: () => c.updateDetailState(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize14,
                            vertical: AppSize.appSize8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColor.primaryColor.withOpacity(.1)
                              : AppColor.whiteColor,
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Text(
                          c.detailStateList[i],
                          style: AppStyle.heading5Medium(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.textColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                );
              }),

              // Corner?
              Text(
                'Corner?',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                return Wrap(
                  spacing: AppSize.appSize12,
                  runSpacing: AppSize.appSize12,
                  children: List.generate(c.cornerList.length, (i) {
                    final selected = c.selectCorner.value == i;
                    return GestureDetector(
                      onTap: () => c.updateCorner(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize14,
                            vertical: AppSize.appSize8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColor.primaryColor.withOpacity(.1)
                              : AppColor.whiteColor,
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Text(
                          c.cornerList[i],
                          style: AppStyle.heading5Medium(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.textColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                );
              }),

              // Furnished?
              Text(
                'Furnished?',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                top: AppSize.appSize26,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              Obx(() {
                return Wrap(
                  spacing: AppSize.appSize12,
                  runSpacing: AppSize.appSize12,
                  children: List.generate(c.furnishedList.length, (i) {
                    final selected = c.selectFurnished.value == i;
                    return GestureDetector(
                      onTap: () => c.updateFurnished(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize14,
                            vertical: AppSize.appSize8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColor.primaryColor.withOpacity(.1)
                              : AppColor.whiteColor,
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Text(
                          c.furnishedList[i],
                          style: AppStyle.heading5Medium(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.textColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ).paddingOnly(
                  top: AppSize.appSize16,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
