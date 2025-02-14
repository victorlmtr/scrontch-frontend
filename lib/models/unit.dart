class Unit {
  final int id;
  final String unitName;

  Unit({
    required this.id,
    required this.unitName,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      unitName: json['unitname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitname': unitName,
    };
  }
}