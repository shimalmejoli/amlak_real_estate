// lib/controller/project_details_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:amlak_real_estate/model/project.dart';
import 'package:amlak_real_estate/model/project_image.dart';
import 'package:amlak_real_estate/fetch/project_service.dart';

class ProjectDetailsController extends GetxController {
  // ─── DYNAMIC DATA ───────────────────────────────────────────────────
  final Rx<Project?> project = Rx<Project?>(null);
  final RxList<ProjectImage> images = <ProjectImage>[].obs;

  // ─── FAVORITE STATE (optional; enable when API ready) ───────────────
  final RxBool isFavorite = false.obs;
  final GetStorage storage = GetStorage();

  // ─── IMAGE CAROUSEL STATE ───────────────────────────────────────────
  final PageController imagePageController = PageController();
  final RxInt currentImagePage = 0.obs;

  // ─── DESCRIPTION TRUNCATION ─────────────────────────────────────────
  static const int aboutWordLimit = 60;
  final RxBool isDescriptionExpanded = false.obs;

  void toggleDescription() => isDescriptionExpanded.toggle();

  String get displayedDescription {
    final desc = project.value?.description?.trim() ?? '';
    final words = desc.split(RegExp(r'\s+'));
    if (words.length <= aboutWordLimit || isDescriptionExpanded.value) {
      return desc;
    }
    return words.take(aboutWordLimit).join(' ') + '…';
  }

  // ─── SCROLL STATE ───────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _initArgumentsAndLoad();

    // Track carousel page changes
    imagePageController.addListener(() {
      currentImagePage.value = imagePageController.page?.round() ?? 0;
    });
  }

  // ────────────────────────────────────────────────────────────────────
  // Init + Load
  // ────────────────────────────────────────────────────────────────────

  Future<void> _initArgumentsAndLoad() async {
    final args = Get.arguments;

    if (args is Project) {
      project.value = args;
    } else if (args is int) {
      await _loadProject(args);
    } else {
      final id = int.tryParse(args?.toString() ?? '');
      if (id != null && id > 0) {
        await _loadProject(id);
      }
    }

    final p = project.value;
    if (p != null) {
      await _loadImages(p.id);
      // Optional: load favorite once backend is ready
      // await _loadFavorite(p.id);
    }
  }

  Future<void> _loadProject(int id) async {
    try {
      final loaded = await ProjectService.loadProjectDetail(id);
      if (loaded != null) {
        project.value = loaded;
      }
    } catch (e) {
      debugPrint('Error loading project details: $e');
    }
  }

  Future<void> _loadImages(int projectId) async {
    try {
      final gal = await ProjectService.loadProjectImages(projectId);
      images.assignAll(gal);
    } catch (e) {
      debugPrint('Error loading project images: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────────
  // Favorites (optional; uncomment when endpoints exist)
  // ────────────────────────────────────────────────────────────────────

  Future<void> _loadFavorite(int projectId) async {
    try {
      final user = storage.read('user') as Map<String, dynamic>?;
      if (user == null) {
        isFavorite.value = false;
        return;
      }
      final userId = user['id'] as int;
      // isFavorite.value = await ProjectService.checkProjectFavorite(
      //   userId: userId,
      //   projectId: projectId,
      // );
      isFavorite.value = false;
    } catch (_) {
      isFavorite.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    final p = project.value;
    if (p == null) return;

    final user = storage.read('user') as Map<String, dynamic>?;
    if (user == null) {
      // Get.toNamed(AppRoutes.loginView); // if you want to force login
      return;
    }

    final userId = user['id'] as int;
    final projectId = p.id;
    final newVal = !isFavorite.value;
    isFavorite.value = newVal;

    try {
      // final ok = await ProjectService.toggleProjectFavorite(
      //   userId: userId,
      //   projectId: projectId,
      //   add: newVal,
      // );
      // if (!ok) isFavorite.value = !newVal;
      userId;
      projectId; // suppress unused for now
    } catch (e) {
      isFavorite.value = !newVal;
    }
  }

  @override
  void onClose() {
    imagePageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
