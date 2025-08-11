// lib/model/property_detail.dart

import 'dart:convert';
import 'package:amlak_real_estate/configs/app_config.dart';
import 'package:amlak_real_estate/model/service.dart';
import 'package:amlak_real_estate/model/tag.dart';
import 'package:amlak_real_estate/model/user.dart';

class PropertyDetail {
  final int id;
  final String uniqueNumber;
  final String title;
  final String description;
  final String price;
  final String address;
  final int bedrooms;
  final int bathrooms;
  final int area;
  final double latitude;
  final double longitude;

  final String categoryName;
  final String cityName;
  final String state; // from detail_state
  final String availability; // from Properties.state
  final String offerType;
  final String ownershipType;
  final String side;
  final bool isCorner;
  final bool furnished;
  final String listedAt;

  final bool isFavorite; // ← NEW

  /// Holds both the first-image raw path and any legacy `images[]` entries
  final List<String> rawImagePaths;
  final List<Tag> tags;
  final List<Service> services;
  final User owner;

  PropertyDetail({
    required this.id,
    required this.uniqueNumber,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.categoryName,
    required this.cityName,
    required this.state,
    required this.availability,
    required this.offerType,
    required this.ownershipType,
    required this.side,
    required this.isCorner,
    required this.furnished,
    required this.listedAt,
    required this.isFavorite,
    required this.rawImagePaths,
    required this.tags,
    required this.services,
    required this.owner,
  });

  /// Build full image URLs via your `get_image2.php` proxy
  List<String> get imageUrls => rawImagePaths.map((raw) {
        if (raw.startsWith('http://') || raw.startsWith('https://')) {
          return raw;
        }
        final clean = raw.startsWith('/') ? raw.substring(1) : raw;
        final encoded = Uri.encodeComponent(clean);
        return '${AppConfig.apiBase}/amlak/get_image2.php?file=$encoded';
      }).toList();

  factory PropertyDetail.fromJson(Map<String, dynamic> json) {
    String _asString(dynamic v) => v == null ? '' : v.toString();
    bool _asBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = _asString(v).toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    // 1) Extract the new single-image field
    final rawFirst = _asString(json['rawImagePath']);
    // 2) Extract any legacy `images[]` array
    final legacy =
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
            <String>[];
    // 3) Merge them, giving priority to the new field
    final allRaw = <String>[
      if (rawFirst.isNotEmpty) rawFirst,
      ...legacy.where((e) => e.isNotEmpty),
    ];

    return PropertyDetail(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(_asString(json['id'])),
      uniqueNumber: _asString(json['unique_number']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      price: _asString(json['price']),
      address: _asString(json['address']),
      bedrooms: json['bedrooms'] is int
          ? json['bedrooms'] as int
          : int.parse(_asString(json['bedrooms'])),
      bathrooms: json['bathrooms'] is int
          ? json['bathrooms'] as int
          : int.parse(_asString(json['bathrooms'])),
      area: json['area'] is int
          ? json['area'] as int
          : int.parse(_asString(json['area'])),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      categoryName: _asString(json['category_name']),
      cityName: _asString(json['city_name']),
      state: _asString(json['detail_state']),
      availability: _asString(json['availability']),
      offerType: _asString(json['offer_type']),
      ownershipType: _asString(json['ownership_type']),
      side: _asString(json['side']),
      isCorner: _asBool(json['is_corner']),
      furnished: _asBool(json['furnished']),
      listedAt: _asString(json['listed_at']),
      isFavorite: _asBool(json['is_favorite']), // ← NEW
      rawImagePaths: allRaw,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <Tag>[],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <Service>[],
      owner: User.fromJson(json['owner'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'unique_number': uniqueNumber,
        'title': title,
        'description': description,
        'price': price,
        'address': address,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area': area,
        'latitude': latitude,
        'longitude': longitude,
        'category_name': categoryName,
        'city_name': cityName,
        'detail_state': state,
        'availability': availability,
        'offer_type': offerType,
        'ownership_type': ownershipType,
        'side': side,
        'is_corner': isCorner,
        'furnished': furnished,
        'listed_at': listedAt,
        'is_favorite': isFavorite, // ← NEW
        // still emit under `images` for legacy calls
        'images': rawImagePaths,
        'tags': tags
            .map((t) => {
                  'id': t.id,
                  'name': t.name,
                  'image_url': t.rawImageUrl,
                })
            .toList(),
        'services': services
            .map((s) => {
                  'id': s.id,
                  'name': s.name,
                  'image_url': s.rawImageUrl,
                })
            .toList(),
        'owner': {
          'id': owner.id,
          'name': owner.name,
          'email': owner.email,
          'phone': owner.phone,
          'image_url': owner.rawImageUrl,
        },
      };

  @override
  String toString() => jsonEncode(toJson());
}
