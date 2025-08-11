// lib/views/office_list/office_list_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/office_list_controller.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class OfficeListView extends StatelessWidget {
  OfficeListView({Key? key}) : super(key: key);

  final OfficeListController c = Get.put(OfficeListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.offices.isEmpty) {
          return const Center(child: Text('No offices found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: AppSize.appSize10,
            horizontal: AppSize.appSize16,
          ),
          physics: const ClampingScrollPhysics(),
          itemCount: c.offices.length,
          itemBuilder: (context, index) => _officeTile(c.offices[index]),
        );
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () => Get.back(),
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

  Widget _officeTile(User office) {
    // Normalize phone by dropping leading zero
    final raw = office.phone;
    final local = raw.startsWith('0') ? raw.substring(1) : raw;
    final waNumber = '964$local';
    final telNumber = '+964$local';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.officeDetailsView,
        arguments: office.id,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSize.appSize16),
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
            // Avatar + Name + Phone + WhatsApp + Call
            Row(
              children: [
                CircleAvatar(
                  radius: AppSize.appSize22,
                  backgroundColor: AppColor.backgroundColor,
                  backgroundImage: office.avatarUrl.isNotEmpty
                      ? NetworkImage(office.avatarUrl)
                      : null,
                  child: office.avatarUrl.isEmpty
                      ? Icon(Icons.business, size: AppSize.appSize24)
                      : null,
                ).paddingOnly(right: AppSize.appSize10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        office.name,
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
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
                // WhatsApp icon
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse('https://wa.me/$waNumber');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar('Error', 'Could not open WhatsApp');
                    }
                  },
                  child: Image.asset(
                    'assets/icons/whatsapp.png',
                    width: AppSize.appSize30,
                    height: AppSize.appSize30,
                    fit: BoxFit.contain,
                  ),
                ).paddingOnly(right: AppSize.appSize12),
                // Call icon
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

            // small spacing above divider
            const SizedBox(height: AppSize.appSize8),

            // Divider below phone and above email
            Divider(
              color: AppColor.descriptionColor
                  .withValues(alpha: AppSize.appSizePoint4),
              thickness: AppSize.appSizePoint7,
              height: AppSize.appSizePoint7,
            ),

            // small spacing below divider
            const SizedBox(height: AppSize.appSize8),

            // Email + Listing Count (with larger icon)
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
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
