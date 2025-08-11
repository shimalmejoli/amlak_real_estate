// lib/model/project.dart
import 'package:amlak_real_estate/configs/app_config.dart';
import 'package:amlak_real_estate/model/tag.dart';
import 'package:amlak_real_estate/model/service.dart';

/// Simple id+name pair for pivots (display/property categories)
class NamedItem {
  final int id;
  final String name;

  const NamedItem({required this.id, required this.name});

  factory NamedItem.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final nameVal = json['name'];
    final id = (idVal is num)
        ? idVal.toInt()
        : int.tryParse(idVal?.toString() ?? '') ?? 0;
    final name = (nameVal ?? '').toString();
    return NamedItem(id: id, name: name);
  }
}

class Project {
  final int id;
  final String name;
  final String? description;
  final int? cityId;
  final String? cityName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? status;
  final DateTime? startDate;
  final DateTime? completionDate;
  final bool isActive;
  final String? imageUrl;
  final String? price;
  final List<String> categories;

  // Backward-compatible ID arrays
  final List<int> displayCategoryIds;
  final List<int> propertyCategoryIds;
  final List<int> tagIds;
  final List<int> serviceIds;

  // Named arrays
  final List<NamedItem> displayCategoriesNamed;
  final List<NamedItem> propertyCategoriesNamed;

  // Full objects
  final List<Service> services; // now fully loaded from API
  final List<Tag> tagsFull;

  // Fallback named tags
  final List<NamedItem> tagsNamed;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.cityId,
    this.cityName,
    this.address,
    this.latitude,
    this.longitude,
    this.status,
    this.startDate,
    this.completionDate,
    required this.isActive,
    this.imageUrl,
    this.price,
    required this.categories,
    this.displayCategoryIds = const [],
    this.propertyCategoryIds = const [],
    this.tagIds = const [],
    this.serviceIds = const [],
    this.displayCategoriesNamed = const [],
    this.propertyCategoriesNamed = const [],
    this.services = const [],
    this.tagsFull = const [],
    this.tagsNamed = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      final str = v.toString();
      if (str.isEmpty || str == "0000-00-00") return null;
      try {
        return DateTime.parse(str);
      } catch (_) {
        return null;
      }
    }

    List<String> cats = [];
    if (json['categories'] is List) {
      cats = (json['categories'] as List).map((e) => e.toString()).toList();
    }

    List<int> toIntList(dynamic v) {
      if (v is List) {
        return v
            .map((e) {
              if (e is int) return e;
              if (e is num) return e.toInt();
              return int.tryParse(e.toString()) ?? 0;
            })
            .where((x) => x != 0)
            .toList();
      }
      return const [];
    }

    List<NamedItem> toNamedList(dynamic v) {
      if (v is List) {
        return v
            .where((e) => e is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .map(NamedItem.fromJson)
            .toList();
      }
      return const [];
    }

    List<Tag> toTagList(dynamic v) {
      if (v is List) {
        return v
            .where((e) => e is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Tag.fromJson)
            .toList();
      }
      return const [];
    }

    List<Service> toServiceList(dynamic v) {
      if (v is List) {
        return v
            .where((e) => e is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .map(Service.fromJson)
            .toList();
      }
      return const [];
    }

    // Image URL
    final rawImg = json['imageUrl'] ?? json['image_url'];
    String? fullUrl;
    if (rawImg != null && rawImg.toString().isNotEmpty) {
      final imgStr = rawImg.toString();
      fullUrl = imgStr.startsWith('http')
          ? imgStr
          : '${AppConfig.baseUrl}/api/uploads/project/$imgStr';
    }

    return Project(
      id: toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      cityId: toInt(json['cityId'] ?? json['city_id']),
      cityName: json['cityName']?.toString() ?? json['city_name']?.toString(),
      address: json['address']?.toString(),
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      status: json['status']?.toString(),
      startDate: toDate(json['startDate'] ?? json['start_date']),
      completionDate: toDate(json['completionDate'] ?? json['completion_date']),
      isActive: (toInt(json['isActive'] ?? json['is_active']) ?? 0) == 1,
      imageUrl: fullUrl,
      price: json['price']?.toString(),
      categories: cats,
      displayCategoryIds: toIntList(json['displayCategoryIds']),
      propertyCategoryIds: toIntList(json['propertyCategoryIds']),
      tagIds: toIntList(json['tagIds']),
      serviceIds: toIntList(json['serviceIds']),
      displayCategoriesNamed: toNamedList(json['displayCategories']),
      propertyCategoriesNamed: toNamedList(json['propertyCategories']),
      services: toServiceList(json['services']),
      tagsNamed: toNamedList(json['tags']),
      tagsFull: toTagList(json['tags']),
      createdAt: toDate(json['createdAt'] ?? json['created_at']),
      updatedAt: toDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'city_id': cityId,
        'city_name': cityName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'start_date': startDate?.toIso8601String(),
        'completion_date': completionDate?.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'image_url': imageUrl,
        'price': price,
        'categories': categories,
        'displayCategoryIds': displayCategoryIds,
        'propertyCategoryIds': propertyCategoryIds,
        'tagIds': tagIds,
        'serviceIds': serviceIds,
        'displayCategories': displayCategoriesNamed
            .map((e) => {'id': e.id, 'name': e.name})
            .toList(),
        'propertyCategories': propertyCategoriesNamed
            .map((e) => {'id': e.id, 'name': e.name})
            .toList(),
        'services': services.map((e) => e.toJson()).toList(),
        'tags': tagsFull.isNotEmpty
            ? tagsFull
                .map((t) =>
                    {'id': t.id, 'name': t.name, 'image_url': t.rawImageUrl})
                .toList()
            : tagsNamed.map((e) => {'id': e.id, 'name': e.name}).toList(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
