// lib/model/project_unit_detail.dart
class ProjectUnitDetail {
  final int id;
  final int projectUnitId;
  final String unitNumber;
  final int? floor;
  final String description;

  ProjectUnitDetail({
    required this.id,
    required this.projectUnitId,
    required this.unitNumber,
    this.floor,
    required this.description,
  });

  factory ProjectUnitDetail.fromJson(Map<String, dynamic> json) {
    return ProjectUnitDetail(
      id: (json['id'] as num).toInt(),
      projectUnitId: (json['projectUnitId'] as num).toInt(),
      unitNumber: (json['unitNumber'] ?? '').toString(),
      floor: (json['floor'] == null) ? null : (json['floor'] as num).toInt(),
      description: (json['description'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectUnitId': projectUnitId,
        'unitNumber': unitNumber,
        'floor': floor,
        'description': description,
      };
}
