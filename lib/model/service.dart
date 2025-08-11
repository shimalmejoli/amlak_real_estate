// lib/model/service.dart

import 'package:amlak_real_estate/configs/app_config.dart';

class Service {
  final int id;
  final String name;
  final String rawImageUrl;

  Service({
    required this.id,
    required this.name,
    required this.rawImageUrl,
  });

  /// Builds a fully-qualified URL for this service’s icon via the PHP proxy.
  String get imageUrl {
    // If already absolute, return it unchanged:
    if (rawImageUrl.startsWith('http://') ||
        rawImageUrl.startsWith('https://')) {
      return rawImageUrl;
    }
    // Strip any leading slash so the proxy can locate it under uploads/
    final clean =
        rawImageUrl.startsWith('/') ? rawImageUrl.substring(1) : rawImageUrl;
    final encoded = Uri.encodeComponent(clean);
    // Serve from uploads folder via get_image.php
    return '${AppConfig.apiBase}/amlak/get_image.php?file=$encoded';
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    String safeString(dynamic v) {
      if (v == null) return '';
      return v.toString();
    }

    return Service(
      id: safeInt(json['id']),
      name: safeString(json['name']),
      rawImageUrl: safeString(json['image_url']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': rawImageUrl,
      };
}
