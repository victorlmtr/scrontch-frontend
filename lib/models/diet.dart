class Diet {
  final int id;
  final String name;
  final String icon;

  Diet({
    required this.id,
    required this.name,
    required this.icon
  });

  factory Diet.fromJson(Map<String, dynamic> json) {
    return Diet(
      id: json['id'],
      name: json['dietname'],
      icon: json['icon'] ?? '',
    );
  }
}

class UserDiet {
  final int dietId;
  final int userId;
  bool isChecked;

  UserDiet({required this.dietId, required this.userId, this.isChecked = false});

  factory UserDiet.fromJson(Map<String, dynamic> json) {
    return UserDiet(
      dietId: json['dietid'],
      userId: json['userid'],
      isChecked: true,
    );
  }
}
