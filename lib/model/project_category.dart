// lib/model/project_category.dart

class ProjectCategory {
  final int projectId;
  final int propertyCategoryId;

  ProjectCategory({
    required this.projectId,
    required this.propertyCategoryId,
  });

  factory ProjectCategory.fromJson(Map<String, dynamic> json) {
    return ProjectCategory(
      projectId: json['project_id'] as int,
      propertyCategoryId: json['property_category_id'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'project_id': projectId,
        'property_category_id': propertyCategoryId,
      };
}
