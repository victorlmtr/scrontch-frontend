import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/diet.dart';
import '../models/recipe_diet.dart';
import 'api_service.dart';

class DietService {
  final ApiService _apiService;
  final Map<String, String> _standardHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    'Accept-Charset': 'utf-8',
  };
  final Map<int, Diet> _dietCache = {};

  DietService(this._apiService);

  Future<void> updateRecipeDietsWithNames(List<RecipeDiet> recipeDiets) async {
    final Set<int> uniqueDietIds = recipeDiets
        .where((rd) => !_dietCache.containsKey(rd.dietId))
        .map((rd) => rd.dietId)
        .toSet();

    if (uniqueDietIds.isNotEmpty) {
      try {
        final response = await http.get(
          Uri.parse(_apiService.getDietsUrl()),
          headers: _standardHeaders,
        );

        if (response.statusCode == 200) {
          final List<dynamic> diets = json.decode(response.body);
          for (var dietJson in diets) {
            final diet = Diet.fromJson(dietJson);
            _dietCache[diet.id] = diet;
          }
        }
      } catch (e) {
        print('Failed to load diets: $e');
      }
    }

    // Update recipe diets with cached data
    for (var recipeDiet in recipeDiets) {
      final cachedDiet = _dietCache[recipeDiet.dietId];
      if (cachedDiet != null) {
        recipeDiet.updateWithDiet(cachedDiet);
      }
    }
  }

  // Method to clear cache if needed
  void clearCache() {
    _dietCache.clear();
  }
}