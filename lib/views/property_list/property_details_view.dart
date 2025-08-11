// lib/views/property_details/property_details_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:amlak_real_estate/common/common_button.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/controller/property_details_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PropertyDetailsView extends StatelessWidget {
  PropertyDetailsView({Key? key}) : super(key: key);

  final _ctrl = Get.put(PropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detail = _ctrl.detail.value;
      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: _buildAppBar(),
        body: detail == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, detail),
        bottomNavigationBar: _buildBottomButton(),
      );
    });
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
        // Search icon
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.searchView),
          child: Image.asset(
            Assets.images.search.path,
            width: AppSize.appSize24,
            color: AppColor.descriptionColor,
          ),
        ).paddingOnly(right: AppSize.appSize26),

        // Favorite toggle using your save/save­d asset icons
        Obx(() {
          final fav = _ctrl.isFavorite.value;
          return GestureDetector(
            onTap: () {
              final user = _ctrl.storage.read('user');
              if (user == null) {
                // not logged in → go to login
                Get.toNamed(AppRoutes.loginView);
              } else {
                // already logged in → toggle favorite
                _ctrl.toggleFavorite();
              }
            },
            child: Image.asset(
              fav ? Assets.images.saved.path : Assets.images.save.path,
              width: AppSize.appSize24,
              color: fav ? Colors.red : AppColor.descriptionColor,
            ),
          ).paddingOnly(right: AppSize.appSize26);
        }),

        // Share icon
        GestureDetector(
          onTap: () => Share.share(AppString.appName),
          child: Image.asset(
            Assets.images.share.path,
            width: AppSize.appSize24,
          ),
        ).paddingOnly(right: AppSize.appSize16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: _buildTabBar(),
      ),
    );
  }

  void _onSaveTapped() {
    Get.back();
    Get.back();
    Get.back();
    Future.delayed(const Duration(milliseconds: AppSize.size400), () {
      final bb = Get.find<BottomBarController>();
      bb.pageController.jumpToPage(AppSize.size3);
    });
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: AppSize.appSize40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
        itemCount: _ctrl.propertyList.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _ctrl.updateProperty(i),
          child: Obx(() {
            final sel = _ctrl.selectProperty.value == i;
            return Container(
              height: AppSize.appSize25,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSize.appSize14),
              margin: const EdgeInsets.only(right: AppSize.appSize16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: sel ? AppColor.primaryColor : AppColor.borderColor,
                    width: AppSize.appSize1,
                  ),
                  right: BorderSide(
                    color: i == _ctrl.propertyList.length - 1
                        ? Colors.transparent
                        : AppColor.borderColor,
                    width: AppSize.appSize1,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  _ctrl.propertyList[i],
                  style: AppStyle.heading5Medium(
                    color: sel ? AppColor.primaryColor : AppColor.textColor,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PropertyDetail d) {
    return SingleChildScrollView(
      controller: _ctrl.scrollController,
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(d),
          if (d.imageUrls.length > 1) _buildIndicator(d.imageUrls.length),
          _buildPriceSection(d),
          _buildTitleAddressSection(d),
          _buildDivider(),
          _buildFeaturePills(d),
          _buildKeyHighlights(d),
          _buildPropertyDetailsSection(d),
          _buildAboutPropertySection(d),
          _buildPhotoPreviewSection(context),
          _buildFacilitiesSection(d),
          _buildContactOwnerSection(d),
          _buildMapSection(d),
          _buildSimilarHomesSection(),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget _buildImageCarousel(PropertyDetail d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: SizedBox(
        height: AppSize.appSize200,
        child: PageView.builder(
          itemCount: d.imageUrls.length,
          onPageChanged: (i) => _ctrl.currentImagePage.value = i,
          itemBuilder: (_, i) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                child: CachedNetworkImage(
                  imageUrl: d.imageUrls[i],
                  width: double.infinity,
                  height: AppSize.appSize200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[300]),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                ),
              ),

              // existing offer-type badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize10,
                    vertical: AppSize.appSize4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                  child: Text(
                    d.offerType,
                    style:
                        AppStyle.heading3SemiBold(color: AppColor.whiteColor),
                  ),
                ),
              ),

              // ← new availability “ribbon”
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize10,
                    vertical: AppSize.appSize4,
                  ),
                  decoration: BoxDecoration(
                    color: d.availability.toLowerCase() == 'sold'
                        ? Colors.red
                        : Colors.green,
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                  child: Text(
                    d.availability[0].toUpperCase() +
                        d.availability.substring(1),
                    style:
                        AppStyle.heading3SemiBold(color: AppColor.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Center(
      child: Obx(() {
        final p = _ctrl.currentImagePage.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final sel = p == i;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: sel ? 12 : 8,
              height: sel ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? AppColor.primaryColor : AppColor.borderColor,
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildPriceSection(PropertyDetail d) {
    final price = double.tryParse(d.price)?.toInt() ?? d.price;
    return Text(
      '$price',
      style: AppStyle.heading4Medium(color: AppColor.primaryColor),
    ).paddingOnly(
      top: AppSize.appSize16,
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget _buildTitleAddressSection(PropertyDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(d.title,
                style: AppStyle.heading5SemiBold(color: AppColor.textColor))
            .paddingOnly(
          top: AppSize.appSize8,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        Text(d.address,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor))
            .paddingOnly(
          top: AppSize.appSize4,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint4),
      thickness: AppSize.appSizePoint7,
      height: AppSize.appSize0,
    ).paddingOnly(
      top: AppSize.appSize16,
      bottom: AppSize.appSize16,
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget _buildFeaturePills(PropertyDetail d) {
    return Row(
      children: [
        if (d.bedrooms > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSize.appSize6,
              horizontal: AppSize.appSize14,
            ),
            margin: const EdgeInsets.only(right: AppSize.appSize16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.primaryColor,
                width: AppSize.appSizePoint50,
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
                  d.bedrooms.toString(),
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
              ],
            ),
          ),
        if (d.bathrooms > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppSize.appSize6,
              horizontal: AppSize.appSize14,
            ),
            margin: const EdgeInsets.only(right: AppSize.appSize16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.primaryColor,
                width: AppSize.appSizePoint50,
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
                  d.bathrooms.toString(),
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
              ],
            ),
          ),
        // area is always shown
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSize.appSize6,
            horizontal: AppSize.appSize14,
          ),
          margin: const EdgeInsets.only(right: AppSize.appSize16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: AppColor.primaryColor,
              width: AppSize.appSizePoint50,
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
                '${d.area} sq/m',
                style: AppStyle.heading5Medium(color: AppColor.textColor),
              ),
            ],
          ),
        ),
      ],
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
    );
  }

  Widget _buildKeyHighlights(PropertyDetail d) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSize.appSize16),
      margin: const EdgeInsets.only(
        top: AppSize.appSize36,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppString.keyHighlights,
                style: AppStyle.heading4SemiBold(color: AppColor.whiteColor))
            .paddingOnly(bottom: AppSize.appSize10),
        ...d.tags.map((tag) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSize.appSize10),
            child: Row(children: [
              SvgPicture.network(
                tag.imageUrl,
                width: AppSize.appSize18,
                height: AppSize.appSize18,
                placeholderBuilder: (_) => SizedBox(
                  width: AppSize.appSize18,
                  height: AppSize.appSize18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(tag.name,
                    style:
                        AppStyle.heading5Regular(color: AppColor.whiteColor)),
              ),
            ]),
          );
        }).toList(),
      ]),
    );
  }

  Widget _buildPropertyDetailsSection(PropertyDetail d) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppSize.appSize36,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        color: AppColor.secondaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.propertyDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize16,
          ),
          const SizedBox(height: AppSize.appSize8),
          _detailRow('Category', d.categoryName),
          _detailRow('City', d.cityName),
          _detailRow('State', d.state), // ← New State row
          _detailRow('Address', d.address),
          _detailRow('Offer type', d.offerType),
          _detailRow('Ownership', d.ownershipType),
          _detailRow('Side', d.side),
          _detailRow('Corner plot', d.isCorner ? 'Yes' : 'No'),
          _detailRow('Furnished', d.furnished ? 'Yes' : 'No'),
          _detailRow('Unique No.', d.uniqueNumber),
          _detailRow('Listed on', d.listedAt),
          const SizedBox(height: AppSize.appSize16),
        ],
      ),
    );
  }

  // lib/views/property_details/property_details_view.dart

  Widget _buildAboutPropertySection(PropertyDetail d) {
    return Obx(() {
      final desc = d.description;
      final words = desc.split(RegExp(r'\s+'));
      // now uses the public constant:
      final isLong = words.length > PropertyDetailsController.aboutWordLimit;
      final isExpanded = _ctrl.isDescriptionExpanded.value;
      final displayText = _ctrl.displayedDescription;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.aboutProperty,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            margin: const EdgeInsets.only(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.descriptionColor.withValues(
                  alpha: AppSize.appSizePoint50,
                ),
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                ),
                if (isLong)
                  GestureDetector(
                    onTap: _ctrl.toggleDescription,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSize.appSize8),
                      child: Text(
                        isExpanded ? 'Hide' : 'Read more',
                        style: AppStyle.heading5Medium(
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPhotoPreviewSection(BuildContext c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppString.takeATourOfOurProperty,
              style: AppStyle.heading4SemiBold(color: AppColor.textColor))
          .paddingOnly(
        top: AppSize.appSize36,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.galleryView),
        child: _previewTile(
          c,
          imagePath: Assets.images.hall.path,
          label: AppString.hall,
        ),
      ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.galleryView),
            child: _previewTile(
              c,
              imagePath: Assets.images.kitchen.path,
              label: AppString.kitchen,
            ),
          ),
        ),
        const SizedBox(width: AppSize.appSize16),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.galleryView),
            child: _previewTile(
              c,
              imagePath: Assets.images.bedroom.path,
              label: AppString.bedroom,
            ),
          ),
        ),
      ]).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16),
    ]);
  }

  Widget _previewTile(BuildContext c,
      {required String imagePath, required String label}) {
    return Container(
      height: AppSize.appSize150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: MediaQuery.of(c).size.width,
          height: AppSize.appSize75,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppSize.appSize13),
              bottomRight: Radius.circular(AppSize.appSize13),
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(label,
                    style: AppStyle.heading3Medium(color: AppColor.whiteColor))
                .paddingOnly(
              left: AppSize.appSize16,
              bottom: AppSize.appSize16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection(PropertyDetail d) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppString.facilities,
              style: AppStyle.heading4Medium(color: AppColor.textColor))
          .paddingOnly(
        top: AppSize.appSize36,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      SizedBox(
        height: AppSize.appSize110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: AppSize.appSize16),
          itemCount: d.services.length,
          itemBuilder: (_, i) {
            final svc = d.services[i];
            final url = svc.imageUrl.toLowerCase();
            final icon = url.endsWith('.svg')
                ? SvgPicture.network(
                    svc.imageUrl,
                    width: AppSize.appSize40,
                    height: AppSize.appSize40,
                    placeholderBuilder: (_) => SizedBox(
                      width: AppSize.appSize40,
                      height: AppSize.appSize40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: svc.imageUrl,
                    width: AppSize.appSize40,
                    height: AppSize.appSize40,
                    placeholder: (_, __) => SizedBox(
                      width: AppSize.appSize40,
                      height: AppSize.appSize40,
                    ),
                    errorWidget: (_, __, ___) =>
                        Icon(Icons.broken_image, size: AppSize.appSize40),
                  );
            return Container(
              margin: const EdgeInsets.only(right: AppSize.appSize16),
              padding: const EdgeInsets.symmetric(
                vertical: AppSize.appSize16,
                horizontal: AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                color: AppColor.secondaryColor,
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  icon,
                  Text(svc.name,
                      style:
                          AppStyle.heading5Regular(color: AppColor.textColor)),
                ],
              ),
            );
          },
        ),
      ).paddingOnly(top: AppSize.appSize16),
    ]);
  }

  // Widget _buildContactOwnerSection(PropertyDetail d) {
  //   return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //     Text(AppString.contactToOwner,
  //             style: AppStyle.heading4Medium(color: AppColor.textColor))
  //         .paddingOnly(
  //       top: AppSize.appSize36,
  //       left: AppSize.appSize16,
  //       right: AppSize.appSize16,
  //     ),
  //     Container(
  //       padding: const EdgeInsets.all(AppSize.appSize10),
  //       margin: const EdgeInsets.only(
  //         top: AppSize.appSize16,
  //         left: AppSize.appSize16,
  //         right: AppSize.appSize16,
  //       ),
  //       decoration: BoxDecoration(
  //         color: AppColor.secondaryColor,
  //         borderRadius: BorderRadius.circular(AppSize.appSize12),
  //       ),
  //       child: Row(children: [
  //         ClipOval(
  //           child: CachedNetworkImage(
  //             imageUrl: d.owner.avatarUrl,
  //             width: AppSize.appSize64,
  //             height: AppSize.appSize64,
  //             fit: BoxFit.cover,
  //             placeholder: (_, __) => Container(color: Colors.grey[300]),
  //             errorWidget: (_, __, ___) => Container(color: Colors.grey[300]),
  //           ),
  //         ).paddingOnly(right: AppSize.appSize12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(d.owner.name,
  //                       style:
  //                           AppStyle.heading4Medium(color: AppColor.textColor))
  //                   .paddingOnly(bottom: AppSize.appSize4),
  //               Row(children: [
  //                 Icon(Icons.phone, size: 18, color: AppColor.primaryColor),
  //                 const SizedBox(width: 4),
  //                 Text(d.owner.phone,
  //                     style: AppStyle.heading5Regular(
  //                         color: AppColor.primaryColor)),
  //               ]).paddingOnly(bottom: AppSize.appSize8),
  //               Row(children: [
  //                 Icon(Icons.email, size: 18, color: AppColor.primaryColor),
  //                 const SizedBox(width: 4),
  //                 Text(d.owner.email,
  //                     style: AppStyle.heading5Regular(
  //                         color: AppColor.primaryColor)),
  //               ]),
  //             ],
  //           ),
  //         ),
  //       ]),
  //     ),
  //     CommonButton(
  //       onPressed: () => Get.toNamed(AppRoutes.contactOwnerView),
  //       backgroundColor: AppColor.primaryColor,
  //       child: Text(
  //         AppString.viewPhoneNumberButton,
  //         style: AppStyle.heading5Medium(color: AppColor.whiteColor),
  //       ),
  //     ).paddingOnly(
  //       left: AppSize.appSize16,
  //       right: AppSize.appSize16,
  //       top: AppSize.appSize10,
  //       bottom: AppSize.appSize26,
  //     ),
  //   ]);
  // }
  Widget _buildContactOwnerSection(PropertyDetail d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          AppString.contactToOwner,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // Card container
        Container(
          padding: const EdgeInsets.all(AppSize.appSize10),
          margin: const EdgeInsets.only(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            color: AppColor.secondaryColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Row(
            children: [
              // 1) Avatar
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: d.owner.avatarUrl,
                  width: AppSize.appSize64,
                  height: AppSize.appSize64,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[300]),
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.grey[300]),
                ),
              ).paddingOnly(right: AppSize.appSize12),

              // 2) Name + phone number (no indent)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner name
                    Text(
                      d.owner.name,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize4),

                    // Phone number flush and underlined
                    Text(
                      d.owner.phone,
                      style:
                          AppStyle.heading5Regular(color: AppColor.primaryColor)
                              .copyWith(decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),

              // 3) Action icons (WhatsApp then Call) at the end
              GestureDetector(
                onTap: () => _openWhatsApp(d.owner.phone),
                child: Image.asset(
                  'assets/icons/whatsapp.png',
                  width: AppSize.appSize40,
                  height: AppSize.appSize40,
                  fit: BoxFit.contain,
                ),
              ).paddingOnly(right: AppSize.appSize12),

              GestureDetector(
                onTap: () => _callPhone(d.owner.phone),
                child: Icon(
                  Icons.call,
                  size: AppSize.appSize30,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
        ),

        // “View phone number” button
        // CommonButton(
        //   onPressed: () => Get.toNamed(AppRoutes.contactOwnerView),
        //   backgroundColor: AppColor.primaryColor,
        //   child: Text(
        //     AppString.viewPhoneNumberButton,
        //     style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        //   ),
        // ).paddingOnly(
        //   left: AppSize.appSize16,
        //   right: AppSize.appSize16,
        //   top: AppSize.appSize10,
        //   bottom: AppSize.appSize26,
        // ),
      ],
    );
  }

// Add these two helpers inside your view class:

  Future<void> _callPhone(String phone) async {
    // strip out any non-digits
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // remove leading zero if present
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    // ensure it starts with 964
    final withCode = local.startsWith('964') ? local : '964$local';
    final uri = Uri(scheme: 'tel', path: '+$withCode');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Could not launch dialer');
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // same normalization, but wa.me doesn’t use the '+'
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final local = digits.startsWith('0') ? digits.substring(1) : digits;
    final withCode = local.startsWith('964') ? local : '964$local';
    final uri = Uri.parse('https://wa.me/$withCode');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open WhatsApp');
    }
  }

  Widget _buildMapSection(PropertyDetail d) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppString.exploreMap,
              style: AppStyle.heading4Medium(color: AppColor.textColor))
          .paddingOnly(
        top: AppSize.appSize36,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        child: SizedBox(
          height: AppSize.appSize200,
          width: double.infinity,
          child: GoogleMap(
            onMapCreated: (_) {},
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            markers: {
              Marker(
                markerId: MarkerId('pin'),
                position: LatLng(d.latitude, d.longitude),
              )
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(d.latitude, d.longitude),
              zoom: 12,
            ),
          ),
        ),
      ).paddingOnly(
        top: AppSize.appSize16,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    ]);
  }

  Widget _buildSimilarHomesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppString.similarHomesForYou,
              style: AppStyle.heading4Medium(color: AppColor.textColor))
          .paddingOnly(
        top: AppSize.appSize20,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      SizedBox(
        height: AppSize.appSize372,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: AppSize.appSize16),
          itemCount: _ctrl.searchImageList.length,
          itemBuilder: (_, i) => _buildSimilarTile(i),
        ),
      ).paddingOnly(top: AppSize.appSize16),
    ]);
  }

  Widget _buildSimilarTile(int i) {
    return Container(
      width: AppSize.appSize300,
      padding: const EdgeInsets.all(AppSize.appSize10),
      margin: const EdgeInsets.only(right: AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Image.asset(_ctrl.searchImageList[i], height: AppSize.appSize200),
              Positioned(
                right: AppSize.appSize6,
                top: AppSize.appSize6,
                child: GestureDetector(
                  onTap: () => _ctrl.isSimilarPropertyLiked[i] =
                      !_ctrl.isSimilarPropertyLiked[i],
                  child: Container(
                    width: AppSize.appSize32,
                    height: AppSize.appSize32,
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor
                          .withValues(alpha: AppSize.appSizePoint50),
                      borderRadius: BorderRadius.circular(AppSize.appSize6),
                    ),
                    child: Center(
                      child: Obx(() {
                        final liked = _ctrl.isSimilarPropertyLiked[i];
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ctrl.searchTitleList[i],
                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
              ),
              Text(
                _ctrl.searchAddressList[i],
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ).paddingOnly(top: AppSize.appSize6),
            ],
          ).paddingOnly(top: AppSize.appSize8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _ctrl.searchRupeesList[i],
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              ),
              Row(
                children: [
                  Text(
                    _ctrl.searchRatingList[i],
                    style:
                        AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ).paddingOnly(right: AppSize.appSize6),
                  Image.asset(Assets.images.star.path,
                      width: AppSize.appSize18),
                ],
              ),
            ],
          ).paddingOnly(top: AppSize.appSize6),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _ctrl.searchPropertyImageList.length,
              (j) => Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSize.appSize6, horizontal: AppSize.appSize16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: AppColor.primaryColor,
                    width: AppSize.appSizePoint50,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(_ctrl.searchPropertyImageList[j],
                            width: AppSize.appSize18, height: AppSize.appSize18)
                        .paddingOnly(right: AppSize.appSize6),
                    Text(
                      _ctrl.similarPropertyTitleList[j],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return CommonButton(
      onPressed: () {},
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.ownerDetailsButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      top: AppSize.appSize10,
      bottom: AppSize.appSize26,
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize16,
        vertical: AppSize.appSize12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor)),
          ),
          Expanded(
            child: Text(value,
                style: AppStyle.heading5Regular(color: AppColor.textColor)),
          ),
        ],
      ),
    );
  }
}
