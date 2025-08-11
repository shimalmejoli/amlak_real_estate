// lib/views/agents_list/agents_details_view.dart

import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/agent_details_controller.dart';
import 'package:amlak_real_estate/model/user.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';

class AgentsDetailsView extends StatelessWidget {
  AgentsDetailsView({Key? key}) : super(key: key);

  final AgentDetailsController c = Get.put(AgentDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final agent = c.agent.value;
        if (agent == null) {
          return const Center(child: Text('Agent not found.'));
        }
        // Header + properties list
        return ListView(
          padding: const EdgeInsets.symmetric(
            vertical: AppSize.appSize10,
            horizontal: AppSize.appSize16,
          ),
          children: [
            _agentHeaderTile(agent),
            const SizedBox(height: AppSize.appSize16),
            ...c.listings.map(_propertyTile).toList(),
          ],
        );
      }),
    );
  }

  AppBar _buildAppBar() => AppBar(
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
          AppString.agents,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
      );

  Widget _agentHeaderTile(User agent) {
    // Normalize phone
    final raw = agent.phone;
    final local = raw.startsWith('0') ? raw.substring(1) : raw;
    final waNumber = '964$local';
    final telNumber = '+964 $local';

    return Container(
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
                backgroundImage: agent.avatarUrl.isNotEmpty
                    ? NetworkImage(agent.avatarUrl)
                    : null,
                child: agent.avatarUrl.isEmpty
                    ? Icon(Icons.person, size: AppSize.appSize24)
                    : null,
              ).paddingOnly(right: AppSize.appSize10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name,
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
              // WhatsApp
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse('https://wa.me/$waNumber');
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

          // minimal vertical gap
          const SizedBox(height: AppSize.appSize8),

          // divider with no extra padding
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSizePoint7,
          ),

          // minimal vertical gap
          const SizedBox(height: AppSize.appSize8),

          // Email + property count (larger icon)
          Row(
            children: [
              Icon(Icons.email,
                  size: AppSize.appSize14, color: AppColor.descriptionColor),
              const SizedBox(width: AppSize.appSize6),
              Expanded(
                child: Text(
                  agent.email,
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ),
              Icon(Icons.apartment,
                  size: AppSize.appSize20, color: AppColor.primaryColor),
              const SizedBox(width: AppSize.appSize6),
              Text(
                '${agent.propertyCount}',
                style:
                    AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _propertyTile(PropertyDetail p) {
    // format price
    final priceVal = double.tryParse(p.price)?.toInt() ?? 0;
    final priceText =
        NumberFormat.currency(locale: 'en_US', symbol: '\$ ', decimalDigits: 0)
            .format(priceVal);

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
            // image
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
