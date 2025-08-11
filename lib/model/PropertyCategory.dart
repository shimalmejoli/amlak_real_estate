class PropertyCategory {
  final int id;
  final String name;
  final String imageUrl;

  PropertyCategory(
      {required this.id, required this.name, required this.imageUrl});

  factory PropertyCategory.fromJson(Map<String, dynamic> json) =>
      PropertyCategory(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        name: json['name'],
        imageUrl: json['image_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
      };
}
