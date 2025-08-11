// lib/fetch/fetch.dart

import 'dart:convert';
import 'package:amlak_real_estate/configs/app_config.dart';
import 'package:amlak_real_estate/model/property_detail.dart';
import 'package:amlak_real_estate/model/trending_property.dart';
import 'package:amlak_real_estate/model/PropertyCategory.dart';
import 'package:amlak_real_estate/model/city.dart';
// <-- import your User model
import 'package:amlak_real_estate/model/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String field, message;
  ApiException(this.field, this.message);
  @override
  String toString() => 'ApiException[$field]: $message';
}

class FetchService {
  /// Fetch property categories
  static Future<List<PropertyCategory>> loadPropertyCategories() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBase}/amlak/get_categories.php'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List)
            .map((e) => PropertyCategory.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  /// Fetch popular cities
  static Future<List<City>> loadPopularCities() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiBase}/amlak/get_cities.php'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List).map((e) => City.fromJson(e)).toList();
      }
    }
    return [];
  }

  /// Fetch trending properties
  static Future<List<TrendingProperty>> loadTrendingProperties() async {
    final uri =
        Uri.parse('${AppConfig.apiBase}/amlak/get_trending_properties.php');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if (data['status'] == 'success') {
        return (data['data'] as List)
            .map((e) => TrendingProperty.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  /// Fetch single property detail
  static Future<PropertyDetail?> loadPropertyDetail(int id) async {
    final uri =
        Uri.parse('${AppConfig.apiBase}/amlak/get_property_details.php?id=$id');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body);
      if (map['status'] == 'success') {
        return PropertyDetail.fromJson(map['data']);
      }
    }
    return null;
  }

  /// Offer types
  Future<List<String>> getOfferTypes() async {
    final uri =
        Uri.parse('${AppConfig.apiBase}/amlak/get_property_looking_for.php');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => e.toString()).toList();
    }
    throw Exception(
        'Failed to load offer types (status=${response.statusCode})');
  }

  /// Maximum budget
  Future<double> getMaxPrice() async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_max_price.php');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['max_price'] as num).toDouble();
    }
    throw Exception('Failed to load max price');
  }

  /// Addresses for a city
  static Future<List<String>> loadAddresses(int cityId) async {
    final uri = Uri.parse(
        '${AppConfig.apiBase}/amlak/get_addresses.php?city_id=$cityId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final body = json.decode(resp.body);
      return (body['data'] as List).cast<String>();
    }
    return [];
  }

  /// Count matching properties
  Future<int> getPropertyCount({
    required int cityId,
    required String address,
    required String offerType,
    required double minPrice,
    required double maxPrice,
    required int categoryId,
    required int bedrooms,
    required String side,
    required String detailState,
    required String isCorner,
    required String furnished,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_property_count.php')
        .replace(queryParameters: {
      'city_id': cityId.toString(),
      'address': address,
      'offer_type': offerType,
      'min_price': minPrice.toString(),
      'max_price': maxPrice.toString(),
      'category_id': categoryId.toString(),
      'bedrooms': bedrooms.toString(),
      'side': side,
      'detail_state': detailState,
      'is_corner': isCorner,
      'furnished': furnished,
    });

    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['count'] as int;
    }
    throw Exception('Failed to load property count');
  }

  // ── NEW: User login ─────────────────────────────────────────────────

  /// Attempts to log in. Returns the User on success or throws on failure.
  Future<User> loginUser(
      {required String phone, required String password}) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/login.php');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    // Debug‐print HTTP status & body
    debugPrint('⬆️ POST $uri');
    debugPrint('⬇️ HTTP ${resp.statusCode}: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('Server responded ${resp.statusCode}');
    }
    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    if (map['status'] != 'success') {
      throw Exception(map['message'] ?? 'Login failed');
    }
    return User.fromJson(map['data'] as Map<String, dynamic>);
  }

  /// Fetch paged properties with detailed logging & per-item error catching
  // lib/fetch/fetch.dart

  /// Fetch paged properties, including favorite flag for a logged-in user
  Future<List<PropertyDetail>> getProperties({
    required int cityId,
    required String address,
    required String offerType,
    required double minPrice,
    required double maxPrice,
    required int categoryId,
    required int bedrooms,
    required String side,
    required String detailState,
    required String isCorner,
    required String furnished,
    required int userId, // ← make this required
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_properties.php')
        .replace(queryParameters: {
      'city_id': cityId.toString(),
      'address': address,
      'offer_type': offerType,
      'min_price': minPrice.toString(),
      'max_price': maxPrice.toString(),
      'category_id': categoryId.toString(),
      'bedrooms': bedrooms.toString(),
      'side': side,
      'detail_state': detailState,
      'is_corner': isCorner,
      'furnished': furnished,
      'user_id': userId.toString(), // ← now recognized
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['status'] != 'success' ||
        decoded['data'] is! List) {
      return [];
    }

    return (decoded['data'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => PropertyDetail.fromJson(e))
        .toList();
  }

  static Future<User> loadUser(int id) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_user.php')
        .replace(queryParameters: {'id': id.toString()});
    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception('Failed to load user (status=${resp.statusCode})');
    }

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic> || decoded['status'] != 'success') {
      throw Exception('Unexpected response loading user');
    }

    return User.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  /// Updates the given user. Throws ApiException on 409 (email/phone conflict).
  static Future<void> updateUser({
    required int id,
    required String name,
    required String email,
    required String phone,
    String? password, // optional: if null/empty, server leaves it alone
  }) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/update_user.php');
    final body = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (password != null && password.isNotEmpty) 'password': password,
    };
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(resp.body) as Map<String, dynamic>;

    // conflict errors come back with 409 + {field, message}
    if (resp.statusCode == 409 && data['status'] == 'error') {
      throw ApiException(data['field'] as String, data['message'] as String);
    }
    if (resp.statusCode != 200 || data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }

  /// ── Check if a property is already favorited ───────────────────────────────
  static Future<bool> checkFavorite({
    required int userId,
    required int propertyId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/check_favorite.php')
        .replace(queryParameters: {
      'user_id': userId.toString(),
      'property_id': propertyId.toString(),
    });
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return body['status'] == 'success' && body['is_favorite'] == true;
    }
    throw Exception('Failed to check favorite');
  }

  /// ── Toggle (add/remove) a favorite ────────────────────────────────────────
  static Future<bool> toggleFavorite({
    required int userId,
    required int propertyId,
    required bool add, // true = add, false = remove
  }) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/toggle_favorite.php');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'property_id': propertyId,
        'action': add ? 'add' : 'remove',
      }),
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return body['status'] == 'success';
    }
    throw Exception('Failed to toggle favorite');
  }

  static Future<void> addFavorite(
      {required int userId, required int propertyId}) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/add_favorite.php');
    final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'property_id': propertyId}));

    final data = jsonDecode(resp.body);
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to add favorite');
    }
  }

  static Future<void> removeFavorite(
      {required int userId, required int propertyId}) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/remove_favorite.php');
    final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'property_id': propertyId}));

    final data = jsonDecode(resp.body);
    if (data['status'] != 'success') {
      throw Exception(data['message'] ?? 'Failed to remove favorite');
    }
  }

  Future<List<PropertyDetail>> getSavedProperties({
    required int userId,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_saved_properties.php')
        .replace(queryParameters: {
      'user_id': userId.toString(),
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['status'] != 'success' ||
        decoded['data'] is! List) {
      return [];
    }

    return (decoded['data'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => PropertyDetail.fromJson(e))
        .toList();
  }

  Future<List<User>> getAgents() async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_agents.php');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    if (map['status'] != 'success' || map['data'] is! List) return [];

    return (map['data'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => User.fromJson(e))
        .toList();
  }

  Future<List<User>> getOffices() async {
    final uri = Uri.parse('${AppConfig.apiBase}/amlak/get_offices.php');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    if (map['status'] != 'success' || map['data'] is! List) return [];

    return (map['data'] as List)
        .cast<Map<String, dynamic>>()
        .map((e) => User.fromJson(e))
        .toList();
  }

  /// Fetch only the properties for a given owner ID
  Future<List<PropertyDetail>> getPropertiesByOwner({
    required int ownerId,
    int limit = 20,
    int offset = 0,
  }) async {
    final uri =
        Uri.parse('${AppConfig.apiBase}/amlak/get_properties_by_owner.php')
            .replace(queryParameters: {
      'owner_id': ownerId.toString(),
      'limit': limit.toString(),
      'offset': offset.toString(),
    });

    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['status'] != 'success' ||
        decoded['data'] is! List) {
      return [];
    }

    return (decoded['data'] as List)
        .cast<Map<String, dynamic>>()
        .map((json) => PropertyDetail.fromJson(json))
        .toList();
  }
}
