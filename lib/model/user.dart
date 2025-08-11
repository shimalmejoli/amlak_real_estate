// lib/model/user.dart

import 'package:amlak_real_estate/configs/app_config.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String rawImageUrl;
  final String role;
  final int propertyCount;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.rawImageUrl,
    required this.role,
    required this.propertyCount,
  });

  /// Proxy all non-absolute paths through get_image2.php
  String get avatarUrl {
    if (rawImageUrl.startsWith('http://') ||
        rawImageUrl.startsWith('https://')) {
      return rawImageUrl;
    }
    final clean =
        rawImageUrl.startsWith('/') ? rawImageUrl.substring(1) : rawImageUrl;
    final encoded = Uri.encodeComponent(clean);
    return '${AppConfig.apiBase}/amlak/get_image2.php?file=$encoded';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    String _asString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    int _asInt(dynamic v) {
      if (v is int) return v;
      final s = _asString(v);
      return int.tryParse(s) ?? 0;
    }

    // Prefer 'image_url' but fall back to 'logo_url'
    final rawImage = json['image_url'] ?? json['logo_url'];

    // Prefer property_count but fall back to listing_count
    final rawCount = json['property_count'] ?? json['listing_count'];

    return User(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      email: _asString(json['email']),
      phone: _asString(json['phone']),
      password: _asString(json['password']),
      rawImageUrl: _asString(rawImage),
      role: _asString(json['role']),
      propertyCount: _asInt(rawCount),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'image_url': rawImageUrl,
        'role': role,
        'property_count': propertyCount,
      };

  @override
  String toString() => toJson().toString();
}
