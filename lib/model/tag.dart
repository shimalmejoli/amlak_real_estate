// lib/model/tag.dart

import 'package:amlak_real_estate/configs/app_config.dart';

class Tag {
  final int id;
  final String name;
  final String rawImageUrl;

  Tag({
    required this.id,
    required this.name,
    required this.rawImageUrl,
  });

  /// Builds a fully-qualified URL for this tag’s icon via the PHP proxy.
  String get imageUrl {
    // If it’s already a full URL, return it unchanged:
    if (rawImageUrl.startsWith('http://') ||
        rawImageUrl.startsWith('https://')) {
      return rawImageUrl;
    }

    // Otherwise strip any leading slash and URL-encode the path:
    final clean =
        rawImageUrl.startsWith('/') ? rawImageUrl.substring(1) : rawImageUrl;
    final encoded = Uri.encodeComponent(clean);

    // Use get_image2.php so it resolves from your uploads/ directory:
    return '${AppConfig.apiBase}/amlak/get_image.php?file=$encoded';
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      rawImageUrl: json['image_url'] as String,
    );
  }
}
