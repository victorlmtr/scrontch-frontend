class Diet {
  final int id;
  final String name;  // Assuming the diet has a name or description.

  Diet({required this.id, required this.name});

  factory Diet.fromJson(Map<String, dynamic> json) {
    return Diet(
      id: json['id'],
      name: json['name'],
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
