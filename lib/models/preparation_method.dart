class PreparationMethod {
  final int id;
  final String name;

  PreparationMethod({
    required this.id,
    required this.name,
  });

  factory PreparationMethod.fromJson(Map<String, dynamic> json) {
    return PreparationMethod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}