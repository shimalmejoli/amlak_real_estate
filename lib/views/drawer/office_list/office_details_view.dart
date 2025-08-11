// lib/views/office_details/office_details_view.dart

import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/office_details_controller.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';

class OfficeDetailsView extends StatelessWidget {
  OfficeDetailsView({Key? key}) : super(key: key);

  final OfficeDetailsController c = Get.put(OfficeDetailsController());
  final _currencyFmt = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$ ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.isLoading.value) {
        return const Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final User? office = c.office.value;
      if (office == null) {
        return const Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: Center(child: Text('Office not found.')),
        );
      }

      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: _buildAppBar(),
        body: ListView(
          padding: const EdgeInsets.symmetric(
            vertical: AppSize.appSize10,
            horizontal: AppSize.appSize16,
          ),
          children: [
            _buildHeader(office),
            const SizedBox(height: AppSize.appSize16),
            ...c.listings
                .map((PropertyDetail p) => _buildPropertyTile(p))
                .toList(),
          ],
        ),
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
      title: Text(
        AppString.offices,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget _buildHeader(User office) {
    // Normalize phone and WhatsApp number
    final raw = office.phone;
    final local = raw.startsWith('0') ? raw.substring(1) : raw;
    final telNumber = '+964 $local';
    final waNumber = 'https://wa.me/964$local';

    return Container(
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColor.border2Color,
          width: AppSize.appSizePoint50,
        ),
        borderRadius: BorderRadius.circular(AppSize.appSize16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo, Name, Contact Icons
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.appSize22,
                backgroundColor: AppColor.backgroundColor,
                backgroundImage: NetworkImage(office.avatarUrl),
              ).paddingOnly(right: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      office.name,
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                    const SizedBox(height: AppSize.appSize4),
                    Row(
                      children: [
                        Icon(Icons.phone,
                            size: AppSize.appSize14,
                            color: AppColor.primaryColor),
                        const SizedBox(width: AppSize.appSize6),
                        Text(
                          telNumber,
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(waNumber);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Error', 'Could not open WhatsApp');
                  }
                },
                child: Image.asset(
                  'assets/icons/whatsapp.png',
                  width: AppSize.appSize30,
                  height: AppSize.appSize30,
                ),
              ).paddingOnly(right: AppSize.appSize12),
              GestureDetector(
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: telNumber);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    Get.snackbar('Error', 'Could not launch dialer');
                  }
                },
                child: Icon(
                  Icons.call,
                  size: AppSize.appSize25,
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSize.appSize8),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSizePoint7,
          ),
          const SizedBox(height: AppSize.appSize8),

          // Email and listing count
          Row(
            children: [
              Icon(Icons.email,
                  size: AppSize.appSize14, color: AppColor.descriptionColor),
              const SizedBox(width: AppSize.appSize6),
              Expanded(
                child: Text(
                  office.email,
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ),
              Icon(Icons.apartment,
                  size: AppSize.appSize20, color: AppColor.primaryColor),
              const SizedBox(width: AppSize.appSize6),
              Text(
                '${office.propertyCount}',
                style:
                    AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyTile(PropertyDetail p) {
    final priceVal = double.tryParse(p.price)?.toInt() ?? 0;
    final priceText = _currencyFmt.format(priceVal);

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.propertyDetailsView,
        arguments: p.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSize.appSize16),
        padding: const EdgeInsets.all(AppSize.appSize10),
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              child: CachedNetworkImage(
                imageUrl: p.imageUrls.first,
                height: AppSize.appSize200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey.shade300),
                errorWidget: (_, __, ___) =>
                    Container(color: Colors.grey.shade300),
              ),
            ),
            Text(p.title,
                    style: AppStyle.heading5SemiBold(color: AppColor.textColor))
                .paddingOnly(top: AppSize.appSize16),
            Text(p.address,
                    style: AppStyle.heading5Regular(
                        color: AppColor.descriptionColor))
                .paddingOnly(top: AppSize.appSize6),
            Text(priceText,
                    style:
                        AppStyle.heading5Medium(color: AppColor.primaryColor))
                .paddingOnly(top: AppSize.appSize16),
            Divider(
              color: AppColor.descriptionColor.withOpacity(0.3),
              height: 0,
            ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),
            Row(
              children: [
                if (p.bedrooms > 0)
                  _pill(Assets.images.bed.path, p.bedrooms.toString()),
                if (p.bathrooms > 0)
                  _pill(Assets.images.bath.path, p.bathrooms.toString()),
                _pill(Assets.images.plot.path, '${p.area} sq/m'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSize.appSize6, horizontal: AppSize.appSize14),
      margin: const EdgeInsets.only(right: AppSize.appSize16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.primaryColor, width: 0.5),
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: AppSize.appSize18, height: AppSize.appSize18)
              .paddingOnly(right: AppSize.appSize6),
          Text(text, style: AppStyle.heading5Medium(color: AppColor.textColor)),
        ],
      ),
    );
  }
}
