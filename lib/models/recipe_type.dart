class RecipeType {
  final int id;
  final String typeName;
  final String? typeIcon;

  RecipeType({
    required this.id,
    required this.typeName,
    this.typeIcon,
  });

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    return RecipeType(
      id: json['id'] ?? 0,
      typeName: json['typename'] ?? '',
      typeIcon: json['typeicon'],
    );
  }
}