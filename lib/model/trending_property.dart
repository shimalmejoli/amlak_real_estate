import 'package:amlak_real_estate/configs/app_config.dart';

class TrendingProperty {
  final int id;
  final String title;
  final String address;
  final String price;
  final int bedrooms;
  final int bathrooms;
  final int area;
  final String rawImagePath;
  final String offerType;
  final String categoryName; // ← new

  TrendingProperty({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.rawImagePath,
    required this.offerType,
    required this.categoryName, // ← new
  });

  /// Build the proxied URL
  String get imageUrl =>
      '${AppConfig.apiBase}/amlak/get_image.php?file=$rawImagePath';

  factory TrendingProperty.fromJson(Map<String, dynamic> json) {
    var raw = (json['image_url'] as String);
    final idx = raw.indexOf('/uploads/');
    if (idx != -1) raw = raw.substring(idx + '/uploads/'.length);

    return TrendingProperty(
      id: json['id'] as int,
      title: json['title'] as String,
      address: json['address'] as String,
      price: json['price'].toString(),
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      area: json['area'] as int,
      rawImagePath: raw,
      offerType: json['offer_type'],
      categoryName: json['category_name'], // ← pick up from your PHP
    );
  }
}
