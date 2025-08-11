// lib/views/property_list/property_list_view.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:amlak_real_estate/common/common_rich_text.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/controller/property_list_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/views/property_list/widget/filter_bottom_sheet.dart';

class PropertyListView extends StatelessWidget {
  PropertyListView({Key? key}) : super(key: key);

  final PropertyListController c = Get.put(PropertyListController());

  // Dollar formatter
  final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'en_US',
    symbol: r'$ ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // Keep liked-list in sync
    ever(c.properties, (_) {
      c.isPropertyLiked.assignAll(
        List<bool>.filled(c.properties.length, false),
      );
    });

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: _buildAppBar(),
      body: _buildPropertyList(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: Get.back,
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSize.appSize16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.back();
                  Future.delayed(
                    const Duration(milliseconds: AppSize.size400),
                    () {
                      final bc = Get.put(BottomBarController());
                      bc.pageController.jumpToPage(AppSize.size3);
                    },
                  );
                },
                child: Image.asset(
                  Assets.images.save.path,
                  width: AppSize.appSize24,
                  color: AppColor.descriptionColor,
                ).paddingOnly(right: AppSize.appSize26),
              ),
              GestureDetector(
                onTap: () => Share.share(AppString.appName),
                child: Image.asset(
                  Assets.images.share.path,
                  width: AppSize.appSize24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyList(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + filter bar
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
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSize.appSize16),
                hintText: AppString.searchPropertyText,
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
                prefixIconConstraints:
                    const BoxConstraints(maxWidth: AppSize.appSize51),
                suffixIcon: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                  child: GestureDetector(
                    onTap: () => filterBottomSheet(context),
                    child: Image.asset(Assets.images.filter.path),
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(maxWidth: AppSize.appSize51),
              ),
              onChanged: (val) =>
                  c.searchQuery.value = val.trim().toLowerCase(),
            ),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),

          // Filtered property list
          Obx(() {
            final all = c.properties;
            final q = c.searchQuery.value;
            final filtered = q.isEmpty
                ? all
                : all.where((p) {
                    final lo = q;
                    return p.title.toLowerCase().contains(lo) ||
                        p.address.toLowerCase().contains(lo) ||
                        p.price.toLowerCase().contains(lo) ||
                        p.categoryName.toLowerCase().contains(lo) ||
                        p.cityName.toLowerCase().contains(lo);
                  }).toList();

            if (filtered.isEmpty && c.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final p = filtered[i];
                final rawPrice = double.tryParse(p.price)?.toInt() ?? 0;
                final priceText = _currencyFmt.format(rawPrice);

                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.propertyDetailsView,
                    arguments: p.id,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSize.appSize10),
                    margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image + like icon
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize12),
                              child: CachedNetworkImage(
                                imageUrl: p.imageUrls.isNotEmpty
                                    ? p.imageUrls.first
                                    : '',
                                height: AppSize.appSize200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  height: AppSize.appSize200,
                                  color: Colors.grey.shade300,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  height: AppSize.appSize200,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            Positioned(
                              right: AppSize.appSize6,
                              top: AppSize.appSize6,
                              child: GestureDetector(
                                onTap: () => c.toggleFavorite(i),
                                child: Container(
                                  width: AppSize.appSize32,
                                  height: AppSize.appSize32,
                                  decoration: BoxDecoration(
                                    color: AppColor.whiteColor.withOpacity(0.5),
                                    borderRadius:
                                        BorderRadius.circular(AppSize.appSize6),
                                  ),
                                  child: Center(
                                    child: Obx(() => Image.asset(
                                          c.isPropertyLiked[i]
                                              ? Assets.images.saved.path
                                              : Assets.images.save.path,
                                          width: AppSize.appSize24,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Title & address
                        Text(p.title,
                                style: AppStyle.heading5SemiBold(
                                    color: AppColor.textColor))
                            .paddingOnly(top: AppSize.appSize16),
                        Text(p.address,
                                style: AppStyle.heading5Regular(
                                    color: AppColor.descriptionColor))
                            .paddingOnly(top: AppSize.appSize6),

                        // Price & features
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(priceText,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.primaryColor)),
                            Row(
                              children: [
                                if (p.bedrooms > 0)
                                  _featurePill(
                                      Icons.bed, p.bedrooms.toString()),
                                if (p.bathrooms > 0) ...[
                                  const SizedBox(width: AppSize.appSize8),
                                  _featurePill(
                                      Icons.bathtub, p.bathrooms.toString()),
                                ],
                                const SizedBox(width: AppSize.appSize8),
                                _featurePill(
                                    Icons.square_foot, '${p.area} sq/m'),
                              ],
                            ),
                          ],
                        ).paddingOnly(top: AppSize.appSize16),

                        // Divider
                        Divider(
                          color: AppColor.descriptionColor.withOpacity(0.3),
                          height: 0,
                        ).paddingOnly(
                            top: AppSize.appSize16, bottom: AppSize.appSize16),

                        // Tags
                        Row(
                          children: p.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSize.appSize6,
                                horizontal: AppSize.appSize14,
                              ),
                              margin: const EdgeInsets.only(
                                  right: AppSize.appSize16),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                border: Border.all(
                                    color: AppColor.primaryColor, width: 0.5),
                              ),
                              child: Text(tag.name,
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor)),
                            );
                          }).toList(),
                        ),

                        // Read More button
                        SizedBox(
                          width: double.infinity,
                          height: AppSize.appSize35,
                          child: ElevatedButton(
                            onPressed: () => Get.toNamed(
                              AppRoutes.propertyDetailsView,
                              arguments: p.id,
                            ),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  side: const BorderSide(
                                      color: AppColor.primaryColor, width: 0.7),
                                ),
                              ),
                            ),
                            child: Text('Read More',
                                style: AppStyle.heading6Regular(
                                    color: AppColor.primaryColor)),
                          ),
                        ).paddingOnly(top: AppSize.appSize26),
                      ],
                    ),
                  ),
                );
              },
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            );
          }),
        ],
      ),
    );
  }

  Widget _featurePill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize14,
        vertical: AppSize.appSize6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.primaryColor, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSize.appSize18, color: AppColor.primaryColor),
          const SizedBox(width: 6),
          Text(value,
              style: AppStyle.heading5Medium(color: AppColor.textColor)),
        ],
      ),
    );
  }
}
