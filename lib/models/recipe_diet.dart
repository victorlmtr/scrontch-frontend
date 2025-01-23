import 'diet.dart';

class RecipeDiet {
  final int id;
  final int dietId;
  String? dietName;
  String? dietIcon;

  RecipeDiet({
    required this.id,
    required this.dietId,
    this.dietName,
    this.dietIcon,
  });

  factory RecipeDiet.fromJson(Map<String, dynamic> json) {
    return RecipeDiet(
      id: json['id'] ?? 0,
      dietId: json['dietid'] ?? 0,
      dietName: json['dietName'],
      dietIcon: json['dietIcon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dietid': dietId,
    };
  }

  void updateWithDiet(Diet diet) {
    if (diet.id == dietId) {
      dietName = diet.name;
      dietIcon = diet.icon;
    }
  }
}