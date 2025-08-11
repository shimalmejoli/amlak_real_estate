// lib/model/project_unit.dart
import 'project_unit_detail.dart';
import 'project_unit_price.dart';

class ProjectUnit {
  final int id;
  final int projectId;
  final String unitType;
  final int bedrooms;
  final int bathrooms;
  final double minArea;
  final double maxArea;
  final String side;
  final int totalUnits;
  final DateTime? createdAt;

  // NEW
  final List<ProjectUnitDetail> details;
  final List<ProjectUnitPrice> prices;

  ProjectUnit({
    required this.id,
    required this.projectId,
    required this.unitType,
    required this.bedrooms,
    required this.bathrooms,
    required this.minArea,
    required this.maxArea,
    required this.side,
    required this.totalUnits,
    this.createdAt,
    this.details = const [],
    this.prices = const [],
  });

  factory ProjectUnit.fromJson(Map<String, dynamic> json) {
    double toD(v) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
    int toI(v) => (v is num) ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    final details = (json['details'] is List)
        ? (json['details'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ProjectUnitDetail.fromJson)
            .toList()
        : <ProjectUnitDetail>[];

    final prices = (json['prices'] is List)
        ? (json['prices'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ProjectUnitPrice.fromJson)
            .toList()
        : <ProjectUnitPrice>[];

    DateTime? created;
    final c = json['createdAt'];
    if (c != null && c.toString().isNotEmpty) {
      created = DateTime.tryParse(c.toString());
    }

    return ProjectUnit(
      id: toI(json['id']),
      projectId: toI(json['projectId']),
      unitType: (json['unitType'] ?? '').toString(),
      bedrooms: toI(json['bedrooms']),
      bathrooms: toI(json['bathrooms']),
      minArea: toD(json['minArea']),
      maxArea: toD(json['maxArea']),
      side: (json['side'] ?? '').toString(),
      totalUnits: toI(json['totalUnits']),
      createdAt: created,
      details: details,
      prices: prices,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'unitType': unitType,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'minArea': minArea,
        'maxArea': maxArea,
        'side': side,
        'totalUnits': totalUnits,
        'createdAt': createdAt?.toIso8601String(),
        'details': details.map((e) => e.toJson()).toList(),
        'prices': prices.map((e) => e.toJson()).toList(),
      };
}
