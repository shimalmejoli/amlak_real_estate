// lib/views/home/widget/explore_popular_city.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/home_controller.dart';
import 'package:amlak_real_estate/views/home/widget/explore_city_bottom_sheet.dart';

class ExplorePopularCity extends StatefulWidget {
  const ExplorePopularCity({Key? key}) : super(key: key);

  @override
  _ExplorePopularCityState createState() => _ExplorePopularCityState();
}

class _ExplorePopularCityState extends State<ExplorePopularCity> {
  final HomeController _ctrl = Get.find();
  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Once we have cities, pre-cache their images into Flutter's memory cache:
    if (!_didPrecache && _ctrl.popularCities.isNotEmpty) {
      _didPrecache = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final city in _ctrl.popularCities) {
          precacheImage(NetworkImage(city.imageUrl), context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cities = _ctrl.popularCities;

      // Section header
      final header = Text(
        AppString.explorePopularCity,
        style: AppStyle.heading3SemiBold(color: AppColor.textColor),
      ).paddingOnly(
        top: AppSize.appSize26,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      );

      // Placeholder shimmer while loading
      if (cities.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            SizedBox(
              height: AppSize.appSize100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                itemCount: 4,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: AppSize.appSize16),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: AppSize.appSize100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSize.appSize16),
                      ),
                    ),
                  ),
                ),
              ),
            ).paddingOnly(top: AppSize.appSize16),
          ],
        );
      }

      // Real, cached images
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(
            height: AppSize.appSize100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: cities.length,
              itemBuilder: (ctx, i) {
                final city = cities[i];
                return GestureDetector(
                  onTap: () => exploreCityBottomSheet(context),
                  child: Container(
                    width: AppSize.appSize100,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSize.appSize16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: city.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.white),
                            ),
                            errorWidget: (ctx, url, err) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          // Dark overlay with city name
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              color: Colors.black45,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                city.name,
                                textAlign: TextAlign.center,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.whiteColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      );
    });
  }
}
