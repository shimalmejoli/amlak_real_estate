class NamedItem {
  final int id;
  final String name;
  NamedItem({required this.id, required this.name});

  factory NamedItem.fromJson(Map<String, dynamic> json) {
    return NamedItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}
