// lib/views/project_details/project_details_view.dart

import 'dart:typed_data';

import 'package:amlak_real_estate/configs/app_string.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:amlak_real_estate/configs/app_color.dart';
import 'package:amlak_real_estate/configs/app_size.dart';
import 'package:amlak_real_estate/configs/app_style.dart';
import 'package:amlak_real_estate/gen/assets.gen.dart';
import 'package:amlak_real_estate/model/project.dart';
import 'package:amlak_real_estate/model/project_image.dart';
import 'package:amlak_real_estate/model/project_unit.dart';
import 'package:amlak_real_estate/routes/app_routes.dart';
import 'package:amlak_real_estate/controller/project_details_controller.dart';
import 'package:amlak_real_estate/fetch/project_service.dart';

class ProjectDetailsView extends StatelessWidget {
  ProjectDetailsView({Key? key}) : super(key: key);

  final _c = Get.put(ProjectDetailsController());
  final _money = NumberFormat.currency(symbol: '\$ ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = _c.project.value;
      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: _buildAppBar(),
        body: p == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context, p),
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
          child: Image.asset(
            Assets.images.backArrow.path,
            color: AppColor.textColor, // force black (or your text color)
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      actions: [
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.searchView),
          child: Image.asset(
            Assets.images.search.path,
            width: AppSize.appSize24,
            color: AppColor.descriptionColor,
          ),
        ).paddingOnly(right: AppSize.appSize26),
        Obx(() {
          final fav = _c.isFavorite.value;
          return GestureDetector(
            onTap: _c.toggleFavorite,
            child: Image.asset(
              fav ? Assets.images.saved.path : Assets.images.save.path,
              width: AppSize.appSize24,
              color: fav ? Colors.red : AppColor.descriptionColor,
            ),
          ).paddingOnly(right: AppSize.appSize16);
        }),
      ],
    );
  }

  Widget _buildBody(BuildContext context, Project p) {
    return SingleChildScrollView(
      controller: _c.scrollController,
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(p),
          if (_c.images.isNotEmpty) _buildIndicator(_c.images.length),
          _buildTitleAndLocation(p),

          // Property Categories (below location, above status)
          _buildPropertyCategoriesChips(p),

          _buildStatusAndMeta(p),
          _buildAboutProject(p),

          // Horizontal sections
          _buildTagsSection(p),
          _buildServicesSection(p),

          // NEW: Available Units
          _buildAvailableUnitsSection(p),

          _buildMapSection(p),
          const SizedBox(height: AppSize.appSize26),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Sections
  // ────────────────────────────────────────────────────────────────────

  Widget _buildImageCarousel(Project p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: SizedBox(
        height: AppSize.appSize200,
        child: PageView.builder(
          controller: _c.imagePageController,
          itemCount: _c.images.isNotEmpty
              ? _c.images.length
              : (p.imageUrl?.isNotEmpty == true ? 1 : 0),
          onPageChanged: (i) => _c.currentImagePage.value = i,
          itemBuilder: (_, i) {
            Widget imageWidget;

            if (_c.images.isNotEmpty) {
              final ProjectImage pi = _c.images[i];
              final Uint8List? bytes = pi.bytes;
              imageWidget = (bytes == null)
                  ? Container(color: Colors.grey.shade300)
                  : Image.memory(
                      bytes,
                      width: double.infinity,
                      height: AppSize.appSize200,
                      fit: BoxFit.cover,
                    );
            } else {
              imageWidget = CachedNetworkImage(
                imageUrl: p.imageUrl!,
                width: double.infinity,
                height: AppSize.appSize200,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[300]),
                errorWidget: (_, __, ___) => Container(color: Colors.grey[300]),
              );
            }

            final statusText =
                (p.status == 'completed') ? 'Completed' : 'Under Construction';
            final statusColor =
                (p.status == 'completed') ? Colors.green : Colors.orange;

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  child: imageWidget,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize10,
                      vertical: AppSize.appSize4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize4),
                    ),
                    child: Text(
                      statusText,
                      style:
                          AppStyle.heading3SemiBold(color: AppColor.whiteColor),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIndicator(int count) {
    return Center(
      child: Obx(() {
        final p = _c.currentImagePage.value;
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

  Widget _buildTitleAndLocation(Project p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _toTitleCase(p.name),
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        Row(
          children: [
            Icon(Icons.location_on,
                size: AppSize.appSize16, color: AppColor.primaryColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${p.cityName ?? ''} • ${p.address ?? ''}',
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ).paddingOnly(
          top: AppSize.appSize6,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  // Property Categories as chips
  Widget _buildPropertyCategoriesChips(Project p) {
    final names = p.propertyCategoriesNamed.isNotEmpty
        ? p.propertyCategoriesNamed.map((e) => e.name).toList()
        : (p.propertyCategoryIds.isNotEmpty
            ? p.propertyCategoryIds.map((e) => '#$e').toList()
            : p.categories);

    if (names.isEmpty) return const SizedBox.shrink();

    final palette = [
      Colors.blueAccent.withOpacity(0.15),
      Colors.orangeAccent.withOpacity(0.15),
      Colors.greenAccent.withOpacity(0.15),
      Colors.purpleAccent.withOpacity(0.15),
      Colors.redAccent.withOpacity(0.15),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Categories',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        Wrap(
          spacing: AppSize.appSize6,
          runSpacing: AppSize.appSize6,
          children: names.asMap().entries.map((e) {
            final i = e.key;
            final label = e.value;
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSize.appSize10,
                vertical: AppSize.appSize6,
              ),
              decoration: BoxDecoration(
                color: palette[i % palette.length],
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                label,
                style: AppStyle.heading6Regular(color: AppColor.textColor),
              ),
            );
          }).toList(),
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget _buildStatusAndMeta(Project p) {
    final started = (p.startDate ?? '').toString().trim();
    final completion = (p.completionDate ?? '').toString().trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSize.appSize10),
        Row(
          children: [
            _chip('Status', p.status ?? '-'),
            const SizedBox(width: 8),
            if (started.isNotEmpty) _chip('Start', started),
            const SizedBox(width: 8),
            if (completion.isNotEmpty) _chip('Completion', completion),
          ],
        ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
      ],
    );
  }

  // Tags section (horizontal cards)
  Widget _buildTagsSection(Project p) {
    final hasFull = p.tagsFull.isNotEmpty;
    final tags = p.tagsFull;

    final fallbackLabels = !hasFull
        ? (p.tagsNamed.isNotEmpty
            ? p.tagsNamed.map((e) => e.name).toList()
            : p.tagIds.map((e) => '#$e').toList())
        : const <String>[];

    if (!hasFull && fallbackLabels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        SizedBox(
          height: AppSize.appSize110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            itemCount: hasFull ? tags.length : fallbackLabels.length,
            itemBuilder: (_, i) {
              if (hasFull) {
                final t = tags[i];
                final url = t.imageUrl.toLowerCase();
                final isSvg = url.endsWith('.svg');

                final icon = isSvg
                    ? SvgPicture.network(
                        t.imageUrl,
                        width: AppSize.appSize40,
                        height: AppSize.appSize40,
                        placeholderBuilder: (_) => SizedBox(
                          width: AppSize.appSize40,
                          height: AppSize.appSize40,
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: t.imageUrl,
                        width: AppSize.appSize40,
                        height: AppSize.appSize40,
                        fit: BoxFit.contain,
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
                      SizedBox(
                        width: AppSize.appSize90,
                        child: Text(
                          t.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.heading5Regular(
                            color: AppColor.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                final name = fallbackLabels[i];
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
                      Icon(Icons.tag,
                          size: AppSize.appSize40,
                          color: AppColor.primaryColor),
                      SizedBox(
                        width: AppSize.appSize90,
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.heading5Regular(
                              color: AppColor.textColor),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  // Services section (horizontal cards)
  Widget _buildServicesSection(Project p) {
    if (p.services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.services,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        SizedBox(
          height: AppSize.appSize110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: AppSize.appSize16),
            itemCount: p.services.length,
            itemBuilder: (_, i) {
              final svc = p.services[i];
              final url = svc.imageUrl.toLowerCase();
              final isSvg = url.endsWith('.svg');

              final icon = isSvg
                  ? SvgPicture.network(
                      svc.imageUrl,
                      width: AppSize.appSize40,
                      height: AppSize.appSize40,
                      placeholderBuilder: (_) => SizedBox(
                        width: AppSize.appSize40,
                        height: AppSize.appSize40,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: svc.imageUrl,
                      width: AppSize.appSize40,
                      height: AppSize.appSize40,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => SizedBox(
                        width: AppSize.appSize40,
                        height: AppSize.appSize40,
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          size: AppSize.appSize40),
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
                    SizedBox(
                      width: AppSize.appSize90,
                      child: Text(
                        svc.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  // NEW: Available Units section
  Widget _buildAvailableUnitsSection(Project p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Units',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        FutureBuilder<List<ProjectUnit>>(
          future: ProjectService.loadProjectUnits(p.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: AppSize.appSize16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.only(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16),
                child: Text(
                  'Failed to load units.',
                  style: AppStyle.heading5Regular(color: Colors.red),
                ),
              );
            }
            final units = snap.data ?? const <ProjectUnit>[];
            if (units.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16),
                child: Text(
                  'No units available for this project.',
                  style: AppStyle.heading5Regular(
                      color: AppColor.descriptionColor),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(
                top: AppSize.appSize16,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: units.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSize.appSize12),
              itemBuilder: (_, i) {
                final u = units[i];

                // Compose headline like: "Apartment • 3 Bed • 2 Bath"
                final headlineParts = <String>[];
                if (u.unitType.trim().isNotEmpty) {
                  headlineParts.add(_toTitleCase(u.unitType));
                }
                if (u.bedrooms > 0) headlineParts.add('${u.bedrooms} Bed');
                if (u.bathrooms > 0) headlineParts.add('${u.bathrooms} Bath');
                final headline = headlineParts.join(' • ');

                // Area range
                String areaRange = '';
                if (u.minArea > 0 && u.maxArea > 0) {
                  areaRange =
                      '${u.minArea.toStringAsFixed(0)}–${u.maxArea.toStringAsFixed(0)} sq/m';
                } else if (u.minArea > 0) {
                  areaRange = '${u.minArea.toStringAsFixed(0)} sq/m';
                } else if (u.maxArea > 0) {
                  areaRange = '${u.maxArea.toStringAsFixed(0)} sq/m';
                }

                return Container(
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (headline.isNotEmpty)
                                  Text(
                                    headline,
                                    style: AppStyle.heading4Medium(
                                        color: AppColor.textColor),
                                  ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (areaRange.isNotEmpty)
                                      _chip('Area', areaRange),
                                    if (u.side.trim().isNotEmpty)
                                      _chip('Side', _toTitleCase(u.side)),
                                    if (u.totalUnits > 0)
                                      _chip('Total', '${u.totalUnits}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Price chips row (by area/side)
                      if (u.prices.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: u.prices.map((pr) {
                              final area = pr.area != null
                                  ? '${pr.area!.toStringAsFixed(0)} sq/m'
                                  : '—';
                              final price = pr.price != null
                                  ? _money.format(pr.price)
                                  : '\$ —';
                              final side = pr.side.trim().isNotEmpty
                                  ? ' • ${_toTitleCase(pr.side)}'
                                  : '';
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.whiteColor,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColor.borderColor,
                                  ),
                                ),
                                child: Text(
                                  '$area • $price$side',
                                  style: AppStyle.heading6Regular(
                                      color: AppColor.textColor),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // Expandable unit details list
                      if (u.details.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Theme(
                          data: Theme.of(Get.context!).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            title: Text(
                              'Unit details',
                              style: AppStyle.heading5Medium(
                                  color: AppColor.primaryColor),
                            ),
                            trailing: const Icon(Icons.keyboard_arrow_down),
                            children: [
                              const SizedBox(height: 6),
                              Column(
                                children: u.details.map((d) {
                                  final floor = d.floor != null
                                      ? ' • Floor ${d.floor}'
                                      : '';
                                  final desc = d.description.trim().isNotEmpty
                                      ? '\n${d.description}'
                                      : '';
                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColor.whiteColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColor.borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      'Unit ${d.unitNumber}$floor$desc',
                                      style: AppStyle.heading6Regular(
                                          color: AppColor.textColor),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutProject(Project p) {
    final hasText = (p.description ?? '').trim().isNotEmpty;
    if (!hasText) return const SizedBox.shrink();

    final isLong = p.description!.trim().split(RegExp(r'\s+')).length >
        ProjectDetailsController.aboutWordLimit;

    return Obx(() {
      final expanded = _c.isDescriptionExpanded.value;
      final text = _c.displayedDescription;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Project',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize26,
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
                color: AppColor.descriptionColor
                    .withValues(alpha: AppSize.appSizePoint50),
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                ),
                if (isLong)
                  GestureDetector(
                    onTap: _c.toggleDescription,
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSize.appSize8),
                      child: Text(
                        expanded ? 'Hide' : 'Read more',
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

  Widget _buildMapSection(Project p) {
    if (p.latitude == null || p.longitude == null) {
      return const SizedBox.shrink();
    }
    final lat = p.latitude!;
    final lng = p.longitude!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Map',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
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
                  markerId: const MarkerId('pin'),
                  position: LatLng(lat, lng),
                )
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, lng),
                zoom: 12,
              ),
            ),
          ),
        ).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────

  String _toTitleCase(String text) {
    return text
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
            : w)
        .join(' ');
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style:
                  AppStyle.heading6Regular(color: AppColor.descriptionColor)),
          Text(value,
              style: AppStyle.heading6Regular(color: AppColor.textColor)),
        ],
      ),
    );
  }
}
