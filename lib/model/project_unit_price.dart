// lib/model/project_unit_price.dart
class ProjectUnitPrice {
  final int id;
  final int projectUnitId;
  final double? area; // sq/m
  final String side;
  final double? price;

  ProjectUnitPrice({
    required this.id,
    required this.projectUnitId,
    this.area,
    required this.side,
    this.price,
  });

  factory ProjectUnitPrice.fromJson(Map<String, dynamic> json) {
    double? toD(v) => (v == null)
        ? null
        : (v is num ? v.toDouble() : double.tryParse(v.toString()));
    return ProjectUnitPrice(
      id: (json['id'] as num).toInt(),
      projectUnitId: (json['projectUnitId'] as num).toInt(),
      area: toD(json['area']),
      side: (json['side'] ?? '').toString(),
      price: toD(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectUnitId': projectUnitId,
        'area': area,
        'side': side,
        'price': price,
      };
}
