// lib/fetch/project_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:amlak_real_estate/configs/app_config.dart';
import 'package:amlak_real_estate/model/project.dart';
import 'package:amlak_real_estate/model/project_category.dart';
import 'package:amlak_real_estate/model/project_image.dart';
import 'package:amlak_real_estate/model/project_unit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String field, message;
  ApiException(this.field, this.message);
  @override
  String toString() => 'ApiException[$field]: $message';
}

class ProjectService {
  // ─────────────────────────────────────────────────────────────────────
  // Core helper: GET + JSON with timeout and basic validation
  // ─────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> _getJson(Uri uri,
      {Duration timeout = const Duration(seconds: 15)}) async {
    final res = await http.get(uri).timeout(timeout);
    // if (kDebugMode) {
    //   debugPrint('GET $uri → ${res.statusCode}');
    //   debugPrint('🔄 [RAW JSON] ${res.body}');
    // }
    if (res.statusCode != 200) {
      throw ApiException('http', 'Failed: HTTP ${res.statusCode}');
    }
    final decoded = json.decode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('json', 'Invalid top-level JSON (expected object)');
    }
    return decoded;
  }

  // ─────────────────────────────────────────────────────────────────────
  // Recommended / Listing
  // ─────────────────────────────────────────────────────────────────────
  /// Fetch recommended (active) projects
  static Future<List<Project>> loadRecommendedProjects({int limit = 10}) async {
    final uri = Uri.parse(
      '${AppConfig.apiBase}/amlak/get_recommended_projects.php?limit=$limit',
    );
    final body = await _getJson(uri);
    if (body['status'] != 'success' || body['data'] is! List) {
      throw ApiException('data', 'Invalid response format');
    }
    final list = (body['data'] as List)
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
    // (Optional) de-dupe by id in case backend repeats
    final seen = <int>{};
    return list.where((p) => seen.add(p.id)).toList();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Details
  // ─────────────────────────────────────────────────────────────────────
  /// New: canonical name used by controller/view
  static Future<Project?> loadProjectDetails(int projectId) async {
    final uri = Uri.parse(
      '${AppConfig.apiBase}/amlak/get_project_detail.php?id=$projectId',
    );
    final body = await _getJson(uri);
    if (body['status'] != 'success' || body['data'] == null) return null;
    return Project.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Old name (kept for backward compatibility)
  @Deprecated('Use loadProjectDetails(int) instead')
  static Future<Project?> loadProjectDetail(int projectId) =>
      loadProjectDetails(projectId);

  // ─────────────────────────────────────────────────────────────────────
  // Taxonomies
  // ─────────────────────────────────────────────────────────────────────
  /// Fetch all categories assigned to projects
  static Future<List<ProjectCategory>> loadProjectCategories() async {
    final uri = Uri.parse(
      '${AppConfig.apiBase}/amlak/get_project_categories.php',
    );
    final body = await _getJson(uri);
    if (body['status'] != 'success' || body['data'] is! List) return [];
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(ProjectCategory.fromJson)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Media
  // ─────────────────────────────────────────────────────────────────────
  /// Fetch images for a given project
  static Future<List<ProjectImage>> loadProjectImages(int projectId) async {
    final uri = Uri.parse(
      '${AppConfig.apiBase}/amlak/get_project_images.php?project_id=$projectId',
    );
    final body = await _getJson(uri);
    if (body['status'] != 'success' || body['data'] is! List) return [];
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(ProjectImage.fromJson)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Units / Pricing
  // ─────────────────────────────────────────────────────────────────────
  /// Fetch unit & pricing info for a project
  static Future<List<ProjectUnit>> loadProjectUnits(int projectId) async {
    final uri = Uri.parse(
      '${AppConfig.apiBase}/amlak/get_project_units.php?project_id=$projectId',
    );
    final body = await _getJson(uri);
    if (body['status'] != 'success' || body['data'] is! List) return [];
    return (body['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(ProjectUnit.fromJson)
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Favorites (OPTIONAL — uncomment when backend endpoints are ready)
  // ─────────────────────────────────────────────────────────────────────
  // static Future<bool> checkProjectFavorite({
  //   required int userId,
  //   required int projectId,
  // }) async {
  //   final uri = Uri.parse(
  //     '${AppConfig.apiBase}/amlak/check_project_favorite.php?user_id=$userId&project_id=$projectId',
  //   );
  //   final body = await _getJson(uri);
  //   if (body['status'] != 'success') return false;
  //   return body['data'] == true || body['data'] == 1 || body['data'] == '1';
  // }

  // static Future<bool> toggleProjectFavorite({
  //   required int userId,
  //   required int projectId,
  //   required bool add,
  // }) async {
  //   final uri = Uri.parse(
  //     '${AppConfig.apiBase}/amlak/toggle_project_favorite.php',
  //   );
  //   final res = await http.post(uri, body: {
  //     'user_id': '$userId',
  //     'project_id': '$projectId',
  //     'add': add ? '1' : '0',
  //   }).timeout(const Duration(seconds: 15));
  //   if (kDebugMode) {
  //     debugPrint('POST $uri → ${res.statusCode}');
  //     debugPrint('🔄 [RAW JSON] ${res.body}');
  //   }
  //   if (res.statusCode != 200) return false;
  //   final map = json.decode(res.body);
  //   if (map is! Map<String, dynamic>) return false;
  //   return map['status'] == 'success';
  // }
}
