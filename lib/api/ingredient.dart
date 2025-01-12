class Ingredient {
  final int id;
  late final String name;
  late final String alias;
  late final String image;
  late final String description;
  late final int categoryId;
  bool isSelected;
  bool isEssential;

  Ingredient({
    required this.id,
    required this.name,
    required this.alias,
    required this.image,
    required this.description,
    required this.categoryId,
    this.isSelected = false,
    this.isEssential = false,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      alias: json['alias'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryid'],
    );
  }
}