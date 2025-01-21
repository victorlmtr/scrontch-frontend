import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diet.dart';
import '../models/recipe_diet.dart';
import 'api_service.dart';

class DietService {
  final ApiService _apiService;

  DietService(this._apiService);

  Future<void> updateRecipeDietsWithNames(List<RecipeDiet> recipeDiets) async {
    for (var recipeDiet in recipeDiets) {
      try {
        final response = await http.get(
          Uri.parse('${_apiService.dietsUrl}/${recipeDiet.dietId}'),
        );
        if (response.statusCode == 200) {
          final diet = Diet.fromJson(json.decode(response.body));
          recipeDiet.updateWithDiet(diet);
        }
      } catch (e) {
        print('Failed to load diet ${recipeDiet.dietId}: $e');
      }
    }
  }
}