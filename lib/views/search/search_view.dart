// lib/view/search_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/common/common_button.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/search_filter_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class SearchView extends StatelessWidget {
  SearchView({Key? key}) : super(key: key);

  final SearchFilterController c = Get.put(SearchFilterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: Get.back,
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        AppString.search,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      return c.contentType.value == SearchContentType.search
          ? _searchContent()
          : _filterContent();
    });
  }

  Widget _buildButton() {
    return Obx(() {
      final isSearch = c.contentType.value == SearchContentType.search;
      final count = c.totalCount.value;
      final label = isSearch
          ? '${AppString.continueButton}'
          : 'See All $count ${count == 1 ? "Property" : "Properties"}';
      return Padding(
        padding: const EdgeInsets.only(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          bottom: AppSize.appSize26,
        ),
        child: CommonButton(
          onPressed: () {
            if (isSearch) {
              c.setContent(SearchContentType.searchFilter);
            } else {
              Get.toNamed(AppRoutes.propertyListView);
            }
          },
          backgroundColor: AppColor.primaryColor,
          child: Text(
            isSearch ? AppString.continueButton : label,
            style: AppStyle.heading5Medium(color: AppColor.whiteColor),
          ),
        ),
      );
    });
  }

  Widget _filterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property vs. Commercial toggle
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
            right: AppSize.appSize16),

        // Filters list
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
                  right: AppSize.appSize16),

              // “Looking To” (offer_type)
              Text(
                AppString.lookingTo,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                  top: AppSize.appSize26,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16),
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
                              width: AppSize.appSize1),
                        ),
                        child: Text(
                          c.offerTypeList[i],
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
                    right: AppSize.appSize16);
              }),

              // Budget slider
              Text(
                AppString.budget,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                  top: AppSize.appSize26,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16),
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
                        left: AppSize.appSize16, right: AppSize.appSize16),
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
                                  child: Text(c.startValueText,
                                      style: AppStyle.heading5Medium(
                                          color: AppColor.textColor))),
                            ),
                          ),
                          Text(AppString.toText,
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor))
                              .paddingSymmetric(horizontal: AppSize.appSize26),
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
                                  child: Text(c.endValueText,
                                      style: AppStyle.heading5Medium(
                                          color: AppColor.textColor))),
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
                  right: AppSize.appSize16),
              Obx(() {
                if (c.categoriesLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (c.propertyCategoryList.isEmpty)
                  return const SizedBox.shrink();
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
                              width: AppSize.appSize1),
                        ),
                        child: Text(cat.name,
                            style: AppStyle.heading5Medium(
                                color: selected
                                    ? AppColor.primaryColor
                                    : AppColor.descriptionColor)),
                      ),
                    );
                  }),
                ).paddingOnly(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16);
              }),

              // Number of Bedrooms
              Text(
                AppString.noOfBedrooms,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ).paddingOnly(
                  top: AppSize.appSize26,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16),
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
                              width: AppSize.appSize1),
                        ),
                        child: Center(
                            child: Text(c.bedroomsList[i],
                                style: AppStyle.heading5Medium(
                                    color: selected
                                        ? AppColor.primaryColor
                                        : AppColor.descriptionColor))),
                      ),
                    );
                  }),
                ),
              ).paddingOnly(top: AppSize.appSize16),

              // Side
              Text('Side',
                      style: AppStyle.heading4Medium(color: AppColor.textColor))
                  .paddingOnly(
                      top: AppSize.appSize26,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16),
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
                              width: AppSize.appSize1),
                        ),
                        child: Text(c.sideList[i],
                            style: AppStyle.heading5Medium(
                                color: selected
                                    ? AppColor.primaryColor
                                    : AppColor.textColor)),
                      ),
                    );
                  }),
                ).paddingOnly(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16);
              }),

              // Property State
              Text('Property State',
                      style: AppStyle.heading4Medium(color: AppColor.textColor))
                  .paddingOnly(
                      top: AppSize.appSize26,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16),
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
                              width: AppSize.appSize1),
                        ),
                        child: Text(c.detailStateList[i],
                            style: AppStyle.heading5Medium(
                                color: selected
                                    ? AppColor.primaryColor
                                    : AppColor.textColor)),
                      ),
                    );
                  }),
                ).paddingOnly(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16);
              }),

              // Corner?
              Text('Corner?',
                      style: AppStyle.heading4Medium(color: AppColor.textColor))
                  .paddingOnly(
                      top: AppSize.appSize26,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16),
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
                              width: AppSize.appSize1),
                        ),
                        child: Text(c.cornerList[i],
                            style: AppStyle.heading5Medium(
                                color: selected
                                    ? AppColor.primaryColor
                                    : AppColor.textColor)),
                      ),
                    );
                  }),
                ).paddingOnly(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16);
              }),

              // Furnished?
              Text('Furnished?',
                      style: AppStyle.heading4Medium(color: AppColor.textColor))
                  .paddingOnly(
                      top: AppSize.appSize26,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16),
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
                              width: AppSize.appSize1),
                        ),
                        child: Text(c.furnishedList[i],
                            style: AppStyle.heading5Medium(
                                color: selected
                                    ? AppColor.primaryColor
                                    : AppColor.textColor)),
                      ),
                    );
                  }),
                ).paddingOnly(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _searchContent() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── City display field (no onTap) ─────────────────────────────
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
              decoration: InputDecoration(
                hintText: AppString.searchCity,
                hintStyle:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
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

          // ─── City chips ────────────────────────────────────────────────
          Text(
            AppString.searchCity,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize20,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() {
            if (c.citiesLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Wrap(
              spacing: AppSize.appSize12,
              runSpacing: AppSize.appSize12,
              children: List.generate(c.citiesList.length, (i) {
                final city = c.citiesList[i];
                final isSelected = c.selectCityIndex.value == i;
                return GestureDetector(
                  onTap: () => c.selectCity(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize14,
                      vertical: AppSize.appSize8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColor.primaryColor.withOpacity(.1)
                          : AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Text(
                      city.name,
                      style: AppStyle.heading5Medium(
                        color: isSelected
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

          // ─── Address chips ─────────────────────────────────────────────
          Text(
            'Select Address',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize20,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() {
            if (c.addressesLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Wrap(
              spacing: AppSize.appSize12,
              runSpacing: AppSize.appSize12,
              children: List.generate(c.addressList.length, (i) {
                final addr = c.addressList[i];
                final isSel = c.selectAddressIndex.value == i;
                return GestureDetector(
                  onTap: () => c.selectAddress(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize14,
                      vertical: AppSize.appSize8,
                    ),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColor.primaryColor.withOpacity(.1)
                          : AppColor.whiteColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: isSel
                            ? AppColor.primaryColor
                            : AppColor.borderColor,
                        width: AppSize.appSize1,
                      ),
                    ),
                    child: Text(
                      addr,
                      style: AppStyle.heading5Medium(
                        color:
                            isSel ? AppColor.primaryColor : AppColor.textColor,
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
          // … nothing else here …
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }
}
