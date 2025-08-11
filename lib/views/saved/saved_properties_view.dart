// lib/views/saved_properties/saved_properties_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/controller/saved_properties_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class SavedPropertiesView extends StatelessWidget {
  SavedPropertiesView({Key? key}) : super(key: key);
  final SavedPropertiesController c = Get.put(SavedPropertiesController());

  // Dollar formatter
  final NumberFormat _currencyFmt = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$ ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: _buildAppBar(),
      body: _buildSavedPropertyList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            final bottomBar = Get.find<BottomBarController>();
            bottomBar.pageController.jumpToPage(AppSize.size0);
          },
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        AppString.savedProperties,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: SizedBox(
          height: AppSize.appSize40,
          child: Row(
            children: List.generate(
              c.savedPropertyList.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () => c.updateSavedProperty(index),
                  child: Obx(() {
                    final selected = c.selectSavedProperty.value == index;
                    return Container(
                      height: AppSize.appSize25,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                          right: BorderSide(
                            color: index == c.savedPropertyList.length - 1
                                ? Colors.transparent
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          c.savedPropertyList[index],
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
              ),
            ),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
        ),
      ),
    );
  }

  Widget _buildSavedPropertyList() {
    return Obx(() {
      if (c.savedProperties.isEmpty) {
        return const Center(child: Text('No saved properties.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: AppSize.appSize10,
        ),
        physics: const ClampingScrollPhysics(),
        itemCount: c.savedProperties.length,
        itemBuilder: (context, index) {
          final p = c.savedProperties[index];
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
                  // Image + unsave icon
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        child: CachedNetworkImage(
                          imageUrl: p.imageUrls.first,
                          height: AppSize.appSize200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade300),
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey.shade300),
                        ),
                      ),
                      Positioned(
                        right: AppSize.appSize6,
                        top: AppSize.appSize6,
                        child: GestureDetector(
                          onTap: () => c.toggleFavorite(index),
                          child: Container(
                            width: AppSize.appSize32,
                            height: AppSize.appSize32,
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor.withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize6),
                            ),
                            child: Center(
                              child: Obx(() {
                                final liked = c.isPropertyLiked[index];
                                return Image.asset(
                                  liked
                                      ? Assets.images.saved.path
                                      : Assets.images.save.path,
                                  width: AppSize.appSize24,
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Title & address
                  Text(
                    p.title,
                    style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                  ).paddingOnly(top: AppSize.appSize16),
                  Text(
                    p.address,
                    style: AppStyle.heading5Regular(
                        color: AppColor.descriptionColor),
                  ).paddingOnly(top: AppSize.appSize6),

                  // Price in money format
                  Text(
                    _currencyFmt.format(double.tryParse(p.price)?.toInt() ?? 0),
                    style:
                        AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ).paddingOnly(top: AppSize.appSize16),

                  // Divider
                  Divider(
                    color: AppColor.descriptionColor.withOpacity(0.3),
                    height: 0,
                  ).paddingOnly(
                      top: AppSize.appSize16, bottom: AppSize.appSize16),

                  // Feature pills: bedrooms, bathrooms (only if >0), area
                  Row(
                    children: [
                      if (p.bedrooms > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSize.appSize6,
                            horizontal: AppSize.appSize14,
                          ),
                          margin:
                              const EdgeInsets.only(right: AppSize.appSize16),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            border: Border.all(
                              color: AppColor.primaryColor,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                Assets.images.bed.path,
                                width: AppSize.appSize18,
                                height: AppSize.appSize18,
                              ).paddingOnly(right: AppSize.appSize6),
                              Text(
                                p.bedrooms.toString(),
                                style: AppStyle.heading5Medium(
                                    color: AppColor.textColor),
                              ),
                            ],
                          ),
                        ),
                      if (p.bathrooms > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSize.appSize6,
                            horizontal: AppSize.appSize14,
                          ),
                          margin:
                              const EdgeInsets.only(right: AppSize.appSize16),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            border: Border.all(
                              color: AppColor.primaryColor,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                Assets.images.bath.path,
                                width: AppSize.appSize18,
                                height: AppSize.appSize18,
                              ).paddingOnly(right: AppSize.appSize6),
                              Text(
                                p.bathrooms.toString(),
                                style: AppStyle.heading5Medium(
                                    color: AppColor.textColor),
                              ),
                            ],
                          ),
                        ),
                      // area always shown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSize.appSize6,
                          horizontal: AppSize.appSize14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: AppColor.primaryColor,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              Assets.images.plot.path,
                              width: AppSize.appSize18,
                              height: AppSize.appSize18,
                            ).paddingOnly(right: AppSize.appSize6),
                            Text(
                              '${p.area} sq/m',
                              style: AppStyle.heading5Medium(
                                  color: AppColor.textColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
