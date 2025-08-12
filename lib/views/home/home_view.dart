import 'package:amlak_real_estate/Fetch/project_service.dart';
import 'package:amlak_real_estate/controller/office_list_controller.dart';
import 'package:amlak_real_estate/controller/search_filter_controller.dart';
import 'package:amlak_real_estate/model/project_image.dart';
import 'package:amlak_real_estate/views/search/search_filter_form.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:amlak_real_estate/common/common_status_bar.dart';
import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/controller/bottom_bar_controller.dart';
import 'package:amlak_real_estate/controller/home_controller.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/views/home/widget/manage_property_bottom_sheet.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends StatelessWidget {
  HomeView({Key? key}) : super(key: key);
  final HomeController homeController = Get.put(HomeController());
  final GetStorage _storage = GetStorage(); // ← add this
  final ScrollController _newPropsController = ScrollController();
  double get _scrollAmount => AppSize.appSize300 + AppSize.appSize16;

  final _currencyFmt = NumberFormat.currency(
    locale: 'en_US', // use US locale for grouping
    symbol: '\$', // dollar sign
    decimalDigits: 0, // integer only
  );

  final OfficeListController officeController = Get.put(OfficeListController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: _buildHome(context),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget _buildHome(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildSearchBar(),
          _buildPropertyCategories(),
          _buildExplorePopularCity(context),
          _buildListOfProperties(),
          _buildYourListing(context),
          _buildCountryFilter(),
          _buildRecommendedProjects(),

          // ② Instead of recent responses, load offices here:
          _buildOfficeSection(),

          //  _buildPopularBuilders(),
          _buildUpcomingProjects(),
        ],
      ).paddingOnly(
        top: AppSize.appSize50,
        bottom: AppSize.appSize20,
      ),
    );
  }

  // 1. Greeting Header
  Widget _buildHeader(BuildContext context) {
    // Read user name or default to "Guest"
    final userMap = _storage.read('user') as Map<String, dynamic>?;
    final userName = (userMap != null &&
            userMap['name'] != null &&
            (userMap['name'] as String).trim().isNotEmpty)
        ? userMap['name'] as String
        : 'Guest';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Image.asset(
                Assets.images.drawer.path,
                width: AppSize.appSize40,
                height: AppSize.appSize40,
              ).paddingOnly(right: AppSize.appSize16),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic greeting
                Text(
                  'Hi, $userName',
                  style:
                      AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
                Text(
                  AppString.welcome,
                  style: AppStyle.heading3Medium(color: AppColor.primaryColor),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.notificationView),
          child: Image.asset(
            Assets.images.notification.path,
            width: AppSize.appSize40,
            height: AppSize.appSize40,
          ),
        ),
      ],
    ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16);
  }

  // 2. Property Categories
  Widget _buildPropertyCategories() {
    return Obx(() {
      if (homeController.propertyOptionList.isEmpty) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(left: AppSize.appSize16),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              4,
              (_) => Container(
                width: 80,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ).paddingOnly(top: AppSize.appSize26);
      }
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            homeController.propertyOptionList.length,
            (index) {
              final category = homeController.propertyOptionList[index];
              final selected = homeController.selectProperty.value == index;
              return GestureDetector(
                onTap: () {
                  homeController.updateProperty(index);
                  if (index == AppSize.size7) {
                    Get.toNamed(AppRoutes.postPropertyView);
                  }
                },
                child: Container(
                  height: AppSize.appSize37,
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSize.appSize14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    color: selected
                        ? AppColor.primaryColor
                        : AppColor.backgroundColor,
                  ),
                  child: Row(
                    children: [
                      if (category.imageUrl.isNotEmpty)
                        Image.network(
                          category.imageUrl,
                          width: AppSize.appSize24,
                          height: AppSize.appSize24,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ).paddingOnly(right: AppSize.appSize8),
                      Text(
                        category.name,
                        style: AppStyle.heading5Regular(
                          color: selected
                              ? AppColor.whiteColor
                              : AppColor.descriptionColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ).paddingOnly(top: AppSize.appSize26);
    });
  }

  // 3. Search Bar
  Widget _buildSearchBar() {
    return Container(
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
        controller: homeController.searchController,
        cursorColor: AppColor.primaryColor,
        style: AppStyle.heading4Regular(color: AppColor.textColor),
        readOnly: true,
        onTap: () => Get.toNamed(AppRoutes.searchView),
        decoration: InputDecoration(
          hintText: AppString.searchCity,
          hintStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(
                left: AppSize.appSize16, right: AppSize.appSize16),
            child: Image.asset(Assets.images.search.path),
          ),
          prefixIconConstraints:
              const BoxConstraints(maxWidth: AppSize.appSize51),
        ),
      ),
    ).paddingOnly(
        top: AppSize.appSize20,
        left: AppSize.appSize16,
        right: AppSize.appSize16);
  }

  // 4. Your Listing
  Widget _buildYourListing(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.yourListing,
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
            ),
            GestureDetector(
              onTap: () {
                final bottomBarController = Get.put(BottomBarController());
                bottomBarController.pageController.jumpToPage(AppSize.size1);
              },
              child: Text(
                AppString.viewAll,
                style:
                    AppStyle.heading5Medium(color: AppColor.descriptionColor),
              ),
            ),
          ],
        ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16),
        Container(
          padding: const EdgeInsets.all(AppSize.appSize10),
          margin: const EdgeInsets.only(top: AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Image.asset(
                  Assets.images.property1.path,
                  width: AppSize.appSize112,
                ).paddingOnly(right: AppSize.appSize16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        AppString.rupees50Lac,
                        style:
                            AppStyle.heading5Medium(color: AppColor.whiteColor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppString.sellFlat,
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.whiteColor),
                          ),
                          Text(
                            AppString.northBombaySociety,
                            style: AppStyle.heading5Regular(
                                color: AppColor.whiteColor),
                          ),
                        ],
                      ),
                      IntrinsicWidth(
                        child: GestureDetector(
                          onTap: () => managePropertyBottomSheet(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppString.manageProperty,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.whiteColor),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: AppSize.appSize3),
                                height: AppSize.appSize1,
                                color: AppColor.whiteColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
      ],
    );
  }

  // 5. Country Filter
  Widget _buildCountryFilter() {
    return Obx(() {
      final cities = homeController.cities;
      final selected = homeController.selectedCityIndex.value;
      // We’ll build: [All] + cities + [Others]
      final totalTabs = cities.length + 2;

      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(totalTabs, (i) {
            final isLast = i == totalTabs - 1;
            final isSel = selected == i;
            String label;
            if (i == 0) {
              label = 'All';
            } else if (i == totalTabs - 1) {
              label = 'Others';
            } else {
              label = cities[i - 1].name;
            }

            return GestureDetector(
              onTap: () => homeController.selectedCityIndex.value = i,
              child: Container(
                height: AppSize.appSize25,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSel ? AppColor.primaryColor : AppColor.borderColor,
                      width: AppSize.appSize1,
                    ),
                    right: BorderSide(
                      color: isLast ? Colors.transparent : AppColor.borderColor,
                      width: AppSize.appSize1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppStyle.heading5Medium(
                      color: isSel ? AppColor.primaryColor : AppColor.textColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ).paddingOnly(top: AppSize.appSize36);
    });
  }

  // 6. Recommended Projects
  // At the top of HomeView.dart, ensure you have:

  /// Inside your HomeView class:
  // Inside your HomeView class:
  /// Converts "hello world" → "Hello World"
  String toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  Widget _buildRecommendedProjects() {
    // Badge background palette
    final badgePalette = [
      Colors.blueAccent.withOpacity(0.2),
      Colors.orangeAccent.withOpacity(0.2),
      Colors.greenAccent.withOpacity(0.2),
      Colors.purpleAccent.withOpacity(0.2),
      Colors.redAccent.withOpacity(0.2),
    ];

    return Obx(() {
      final isLoading = homeController.projectsLoading.value;
      final list = homeController.recommendedProjects;

      // Header with “Recommended Projects” title and “View All” link
      final header = Padding(
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppString.recommendedProject,
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.propertyListView),
              child: Text(
                AppString.viewAll,
                style:
                    AppStyle.heading5Medium(color: AppColor.descriptionColor),
              ),
            ),
          ],
        ),
      );

      if (isLoading) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const Center(child: CircularProgressIndicator()),
          ],
        );
      }

      if (list.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: AppSize.appSize48),
            Center(
              child: Text(
                'No projects available.',
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(
            height: AppSize.appSize372,
            child: ListView.builder(
              controller: _newPropsController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: list.length,
              itemBuilder: (ctx, idx) {
                final project = list[idx]; // ✅ define `project` here

                // Determine ribbon text & color
                final statusText = project.status == 'completed'
                    ? 'Completed'
                    : 'Under Construction';
                final statusColor = project.status == 'completed'
                    ? Colors.green
                    : Colors.orange;

                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.projectDetailsView, // ✅ go to ProjectDetails
                    arguments: project.id, // ✅ pass the id
                  ),
                  child: Container(
                    width: AppSize.appSize300,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    padding: const EdgeInsets.all(AppSize.appSize10),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image + status ribbon
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize12),
                              child: FutureBuilder<List<ProjectImage>>(
                                future: ProjectService.loadProjectImages(
                                    project.id),
                                builder: (context, snap) {
                                  if (snap.connectionState !=
                                          ConnectionState.done ||
                                      snap.data == null ||
                                      snap.data!.isEmpty ||
                                      snap.data!.first.bytes == null) {
                                    return Container(
                                      height: AppSize.appSize200,
                                      color: Colors.grey.shade300,
                                    );
                                  }
                                  return Image.memory(
                                    snap.data!.first.bytes!,
                                    height: AppSize.appSize200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  statusText,
                                  style: AppStyle.heading6Regular(
                                    color: AppColor.whiteColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Project name
                        Text(
                          toTitleCase(project.name),
                          style: AppStyle.heading5SemiBold(
                            color: AppColor.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Location
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: AppSize.appSize16,
                                color: AppColor.primaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${project.cityName ?? ''} • ${project.address ?? ''}',
                                style: AppStyle.heading5Regular(
                                  color: AppColor.descriptionColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Category badges
                        Wrap(
                          spacing: AppSize.appSize6,
                          runSpacing: AppSize.appSize4,
                          children:
                              project.categories.asMap().entries.map((entry) {
                            final i = entry.key;
                            final cat = entry.value;
                            final bg = badgePalette[i % badgePalette.length];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.appSize8,
                                vertical: AppSize.appSize4,
                              ),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize8),
                              ),
                              child: Text(
                                cat,
                                style: AppStyle.heading6Regular(
                                    color: AppColor.textColor),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),

                        // Description
                        Text(
                          project.description ?? '',
                          style: AppStyle.heading6Regular(
                            color: AppColor.descriptionColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).paddingOnly(top: AppSize.appSize16),
          ),
        ],
      );
    });
  }

  Widget _buildOfficeSection() {
    const int maxOnHome = 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: title + View All
        Padding(
          padding: const EdgeInsets.only(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.offices,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.officeListView),
                child: Text(
                  AppString.viewAll,
                  style:
                      AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ),
        ),

        // ← Add spacing here
        const SizedBox(height: AppSize.appSize16),

        // Horizontal list of up to 5 office cards
        SizedBox(
          height: AppSize.appSize180,
          child: Obx(() {
            if (officeController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final offices = officeController.offices;
            if (offices.isEmpty) {
              return Center(
                child: Text(
                  'No offices found.',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                ),
              );
            }

            // show at most maxOnHome offices
            final count =
                offices.length > maxOnHome ? maxOnHome : offices.length;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: count,
              itemBuilder: (_, index) {
                final o = offices[index];
                final raw = o.phone;
                final local = raw.startsWith('0') ? raw.substring(1) : raw;
                final waUrl = 'https://wa.me/964$local';

                return Container(
                  width: AppSize.appSize160,
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSize.appSize12,
                    horizontal: AppSize.appSize8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: AppSize.appSize28,
                        backgroundColor: AppColor.backgroundColor,
                        backgroundImage: o.avatarUrl.isNotEmpty
                            ? NetworkImage(o.avatarUrl)
                            : null,
                        child: o.avatarUrl.isEmpty
                            ? Icon(Icons.business, size: AppSize.appSize28)
                            : null,
                      ),

                      // Name
                      Text(
                        o.name,
                        style: AppStyle.heading5SemiBold(
                            color: AppColor.textColor),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // WhatsApp pill
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(waUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } else {
                            Get.snackbar('Error', 'Could not open WhatsApp');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSize.appSize12,
                            vertical: AppSize.appSize6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/whatsapp.png',
                                width: AppSize.appSize18,
                                height: AppSize.appSize18,
                              ).paddingOnly(right: AppSize.appSize6),
                              Flexible(
                                child: Text(
                                  '+964 $local',
                                  style: AppStyle.heading6Regular(
                                      color: AppColor.primaryColor),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // 8. Based on Search Trends
  // in HomeView:

  Widget _buildListOfProperties() {
    return Obx(() {
      // Wait until categories are loaded
      if (homeController.propertyOptionList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // 1. Grab all trending properties
      final all = homeController.trendingList;

      // 2. Determine which category is selected, clamped to valid range
      final selIdx = homeController.selectProperty.value
          .clamp(0, homeController.propertyOptionList.length - 1);
      final selectedCat = homeController.propertyOptionList[selIdx].name;

      // 3. Filter list by category (or show all)
      final list = (selectedCat == 'All')
          ? all
          : all.where((p) => p.categoryName == selectedCat).toList();

      // 4. Section header with arrows
      final header = Padding(
        padding: EdgeInsets.only(
          top: AppSize.appSize26,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'New Properties',
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
            ),
            GestureDetector(
              onTap: () {
                final pos = _newPropsController.position.pixels;
                _newPropsController.animateTo(
                  (pos - _scrollAmount)
                      .clamp(0.0, _newPropsController.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: _arrowButton(Icons.chevron_left),
            ),
            GestureDetector(
              onTap: () {
                final pos = _newPropsController.position.pixels;
                _newPropsController.animateTo(
                  (pos + _scrollAmount)
                      .clamp(0.0, _newPropsController.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              child: _arrowButton(Icons.chevron_right),
            ),
          ],
        ),
      );

      // 5. If no matches, show a message
      if (list.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                child: Text(
                  'No properties found for “$selectedCat.”',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // 6. Otherwise, build the carousel
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(
            height: AppSize.appSize372,
            child: ListView.builder(
              controller: _newPropsController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: list.length,
              itemBuilder: (ctx, index) {
                final p = list[index];
                final rawPrice = double.tryParse(p.price)?.toInt();
                final priceText =
                    rawPrice != null ? _currencyFmt.format(rawPrice) : p.price;

                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.propertyDetailsView,
                    arguments: p.id,
                  ),
                  child: Container(
                    width: AppSize.appSize300,
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    child: Stack(
                      children: [
                        // Card background
                        Container(
                          padding: const EdgeInsets.all(AppSize.appSize10),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                child: CachedNetworkImage(
                                  imageUrl: p.imageUrl,
                                  height: AppSize.appSize200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (ctx, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(color: Colors.white),
                                  ),
                                  errorWidget: (_, __, ___) =>
                                      Container(color: Colors.grey[300]),
                                ),
                              ),
                              SizedBox(height: AppSize.appSize8),
                              Text(
                                p.title,
                                style: AppStyle.heading5SemiBold(
                                    color: AppColor.textColor),
                              ),
                              Text(
                                p.address,
                                style: AppStyle.heading5Regular(
                                    color: AppColor.descriptionColor),
                              ),
                              SizedBox(height: AppSize.appSize8),
                              Text(
                                priceText,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.primaryColor),
                              ),
                              SizedBox(height: AppSize.appSize8),
                              Row(
                                children: [
                                  if (p.bedrooms > 0)
                                    _featurePill(
                                        Icons.bed, p.bedrooms.toString()),
                                  if (p.bathrooms > 0)
                                    _featurePill(
                                        Icons.bathtub, p.bathrooms.toString()),
                                  _featurePill(
                                      Icons.square_foot, '${p.area} sq/m'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Offer‐type ribbon
                        Positioned(
                          top: AppSize.appSize8,
                          left: AppSize.appSize8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize10,
                              vertical: AppSize.appSize4,
                            ),
                            decoration: BoxDecoration(
                              color: p.offerType == 'rent'
                                  ? Colors.blueAccent
                                  : p.offerType == 'project'
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize4),
                            ),
                            child: Text(
                              p.offerType.toUpperCase(),
                              style: AppStyle.heading6Regular(
                                  color: AppColor.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ).paddingOnly(top: AppSize.appSize16),
          ),
        ],
      );
    });
  }

// Helper to draw the back/forward arrow buttons
  Widget _arrowButton(IconData icon) => Container(
        width: AppSize.appSize40,
        height: AppSize.appSize40,
        margin: const EdgeInsets.only(right: AppSize.appSize8),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(icon, size: 24, color: AppColor.primaryColor),
      );

// Helper for a feature pill
  Widget _featurePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.primaryColor),
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColor.textColor),
          const SizedBox(width: 4),
          Text(text,
              style: AppStyle.heading6Regular(color: AppColor.textColor)),
        ],
      ),
    );
  }

  Widget _buildTrendCard(int index) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.propertyDetailsView),
      child: Container(
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
                Image.asset(
                  homeController.searchImageList[index],
                  height: AppSize.appSize200,
                ),
                Positioned(
                  right: AppSize.appSize6,
                  top: AppSize.appSize6,
                  child: GestureDetector(
                    onTap: () {
                      homeController.isTrendPropertyLiked[index] =
                          !homeController.isTrendPropertyLiked[index];
                    },
                    child: Container(
                      width: AppSize.appSize32,
                      height: AppSize.appSize32,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor
                            .withValues(alpha: AppSize.appSizePoint50),
                        borderRadius: BorderRadius.circular(AppSize.appSize6),
                      ),
                      child: Center(
                        child: Obx(() => Image.asset(
                              homeController.isTrendPropertyLiked[index]
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeController.searchTitleList[index],
                  style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                ),
                Text(
                  homeController.searchAddressList[index],
                  style: AppStyle.heading5Regular(
                      color: AppColor.descriptionColor),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ).paddingOnly(top: AppSize.appSize8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  homeController.searchRupeesList[index],
                  style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                ),
                Row(
                  children: [
                    Text(
                      AppString.rating4Point5,
                      style:
                          AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ).paddingOnly(right: AppSize.appSize6),
                    Image.asset(
                      Assets.images.star.path,
                      width: AppSize.appSize18,
                    ),
                  ],
                ),
              ],
            ).paddingOnly(top: AppSize.appSize6),
            Divider(
                color: AppColor.descriptionColor
                    .withValues(alpha: AppSize.appSizePoint3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                homeController.searchPropertyImageList.length,
                (i) => Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSize.appSize6,
                      horizontal: AppSize.appSize16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    border: Border.all(
                        color: AppColor.primaryColor,
                        width: AppSize.appSizePoint50),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        homeController.searchPropertyImageList[i],
                        width: AppSize.appSize18,
                        height: AppSize.appSize18,
                      ).paddingOnly(right: AppSize.appSize6),
                      Text(
                        homeController.searchPropertyTitleList[i],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 9. Popular Builders
  Widget _buildPopularBuilders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppString.popularBuilders,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor)),
            Text(AppString.inWesternMumbai,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor)),
          ],
        ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16),
        SizedBox(
          height: AppSize.appSize95,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            itemCount: homeController.popularBuilderImageList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (index == AppSize.size0)
                    Get.toNamed(AppRoutes.popularBuildersView);
                },
                child: Container(
                  width: AppSize.appSize160,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSize.appSize16,
                      horizontal: AppSize.appSize10),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(
                          child: Image.asset(
                              homeController.popularBuilderImageList[index],
                              width: AppSize.appSize30,
                              height: AppSize.appSize30)),
                      Center(
                          child: Text(
                              homeController.popularBuilderTitleList[index],
                              style: AppStyle.heading5Medium(
                                  color: AppColor.textColor))),
                    ],
                  ),
                ),
              );
            },
          ),
        ).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  // 10. Upcoming Projects
  Widget _buildUpcomingProjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppString.upcomingProject,
              style: AppStyle.heading3SemiBold(color: AppColor.textColor)),
          Text(AppString.viewAll,
              style: AppStyle.heading5Medium(color: AppColor.descriptionColor)),
        ]).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16),
        SizedBox(
          height: AppSize.appSize320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            itemCount: homeController.upcomingProjectImageList.length,
            itemBuilder: (context, index) {
              return Container(
                width: AppSize.appSize343,
                margin: const EdgeInsets.only(right: AppSize.appSize16),
                padding: const EdgeInsets.all(AppSize.appSize10),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  image: DecorationImage(
                      image: AssetImage(
                          homeController.upcomingProjectImageList[index])),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(homeController.upcomingProjectTitleList[index],
                                style: AppStyle.heading3(
                                    color: AppColor.whiteColor)),
                            Text(homeController.upcomingProjectPriceList[index],
                                style: AppStyle.heading5(
                                    color: AppColor.whiteColor)),
                          ]),
                      Text(homeController.upcomingProjectAddressList[index],
                              style: AppStyle.heading5Regular(
                                  color: AppColor.whiteColor))
                          .paddingOnly(top: AppSize.appSize6),
                      Text(homeController.upcomingProjectFlatSizeList[index],
                              style: AppStyle.heading6Medium(
                                  color: AppColor.whiteColor))
                          .paddingOnly(top: AppSize.appSize6),
                    ]),
              );
            },
          ),
        ).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  // 11. Explore Popular City
  // Widget _buildExplorePopularCity(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Section title (unchanged)
  //       Text(
  //         AppString.explorePopularCity,
  //         style: AppStyle.heading3SemiBold(color: AppColor.textColor),
  //       ).paddingOnly(
  //         top: AppSize.appSize26,
  //         left: AppSize.appSize16,
  //         right: AppSize.appSize16,
  //       ),

  //       // SizedBox wrapper (unchanged)
  //       SizedBox(
  //         height: AppSize.appSize100,
  //         child: Obx(() {
  //           final cities = homeController.popularCities;
  //           return ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             physics: const ClampingScrollPhysics(),
  //             padding: const EdgeInsets.only(left: AppSize.appSize16),
  //             itemCount: cities.length,
  //             itemBuilder: (ctx, index) {
  //               final city = cities[index];
  //               return GestureDetector(
  //                 onTap: () => exploreCityBottomSheet(context),
  //                 child: Container(
  //                   width: AppSize.appSize100,
  //                   margin: const EdgeInsets.only(right: AppSize.appSize16),
  //                   padding: const EdgeInsets.only(bottom: AppSize.appSize10),
  //                   decoration: BoxDecoration(
  //                     color: AppColor.whiteColor,
  //                     borderRadius: BorderRadius.circular(AppSize.appSize16),
  //                     image: DecorationImage(
  //                       // <-- swapped AssetImage for your NetworkImage
  //                       image: NetworkImage(city.imageUrl),
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                   child: Align(
  //                     alignment: Alignment.bottomCenter,
  //                     child: Text(
  //                       city.name, // <-- swapped title list for city.name
  //                       style:
  //                           AppStyle.heading5Medium(color: AppColor.whiteColor),
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         }),
  //       ).paddingOnly(top: AppSize.appSize16),
  //     ],
  //   );
  // }

  Widget _buildExplorePopularCity(BuildContext context) {
    return Obx(() {
      final cities = homeController.popularCities;

      // Section header
      final header = Text(
        AppString.explorePopularCity,
        style: AppStyle.heading3SemiBold(color: AppColor.textColor),
      ).paddingOnly(
        top: AppSize.appSize26,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      );

      // Loading skeleton if cities not yet loaded
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

      // Actual list once cities are available
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
              itemBuilder: (ctx, index) {
                final city = cities[index];
                return GestureDetector(
                  onTap: () {
                    // 1) Instantiate (or retrieve) your full SearchFilterController
                    final searchC = Get.put(SearchFilterController());

                    // 2) Prefill its city list so selectCity() won't be empty
                    searchC.citiesList.assignAll(cities);
                    searchC.citiesLoading.value = false;

                    // 3) Select this city (loads its addresses)
                    searchC.selectCity(index);

                    // 4) Switch to the “filter” view
                    searchC.setContent(SearchContentType.searchFilter);

                    // 5) Show your reusable filter form
                    Get.bottomSheet(
                      const SearchFilterForm(),
                      isScrollControlled: true,
                    );
                  },
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
                            errorWidget: (ctx, url, err) =>
                                Container(color: Colors.grey.shade300),
                          ),
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
                                  color: AppColor.whiteColor,
                                ),
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
