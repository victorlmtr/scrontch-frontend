class NonFoodItem {
  final int id;
  final String name;
  final String? description;

  NonFoodItem({
    required this.id,
    required this.name,
    this.description,
  });

  factory NonFoodItem.fromJson(Map<String, dynamic> json) {
    return NonFoodItem(
      id: json['id'],
      name: json['nonfooditemname'],
      description: json['nonfooditemdescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nonfooditemname': name,
      'nonfooditemdescription': description,
    };
  }
}