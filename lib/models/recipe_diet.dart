import 'diet.dart';

class RecipeDiet {
  final int id;
  final int dietId;
  String? dietName;  // From diet microservice

  RecipeDiet({
    required this.id,
    required this.dietId,
    this.dietName,
  });

  factory RecipeDiet.fromJson(Map<String, dynamic> json) {
    return RecipeDiet(
      id: json['id'] ?? 0,
      dietId: json['dietid'] ?? 0,
      dietName: json['dietName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dietid': dietId,
    };
  }

  // Method to update diet name from Diet microservice data
  void updateWithDiet(Diet diet) {
    if (diet.id == dietId) {
      dietName = diet.name;
    }
  }
}