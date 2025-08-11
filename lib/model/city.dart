// lib/model/city.dart

import 'package:amlak_real_estate/configs/app_config.dart';

class City {
  final int id;
  final String name;

  /// This is exactly the string from `image_url` in your JSON,
  /// e.g. "categories/cityimg_68595e2603d26.jpg",
  /// or sometimes (old cache) already the full proxy URL.
  final String rawPath;

  City({
    required this.id,
    required this.name,
    required this.rawPath,
  });

  /// Every time you need the real image URL, use this getter.
  /// It will prepend the proxy only if `rawPath` isn’t already a URL.
  String get imageUrl {
    // If it already looks like a full HTTP URL, return as‑is:
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }
    // Otherwise, build the one‑time proxy URL:
    final encoded = Uri.encodeComponent(rawPath);
    return '${AppConfig.apiBase}/amlak/get_image.php?file=$encoded';
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] as String,
      // Always store *exactly* what the server gave us:
      rawPath: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    // When caching, write back *only* the rawPath,
    // never the fully‑proxied URL.
    return {
      'id': id,
      'name': name,
      'image_url': rawPath,
    };
  }
}
