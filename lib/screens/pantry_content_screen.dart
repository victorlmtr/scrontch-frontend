import 'package:flutter/material.dart';
import '../api/ingredient.dart';
import '../api/ingredient_category.dart';
import '../api/api_service.dart';
import '../widgets/ingredient_list.dart';

class PantryContentScreen extends StatefulWidget {
  @override
  _PantryContentScreenState createState() => _PantryContentScreenState();
}

class _PantryContentScreenState extends State<PantryContentScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureData;
  List<Ingredient> allIngredients = []; // Store all ingredients
  List<Ingredient> filteredIngredients = []; // Store filtered ingredients
  String searchTerm = ''; // Store the search term

  @override
  void initState() {
    super.initState();
    futureData = Future.wait([
      apiService.fetchIngredients(),
      apiService.fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final ingredients = (snapshot.data![0] as List<dynamic>)
              .map((json) => Ingredient.fromJson(json))
              .toList();
          final categories = (snapshot.data![1] as List<dynamic>)
              .map((json) => IngredientCategory.fromJson(json))
              .toList();

          // Store all ingredients for filtering
          allIngredients = ingredients;
          filteredIngredients = ingredients; // Initialize filtered list

          // Group ingredients by category ID
          final groupedIngredients = <int, List<Ingredient>>{};
          for (var ingredient in ingredients) {
            groupedIngredients.putIfAbsent(ingredient.categoryId, () => []).add(ingredient);
          }

          // Display all categories, even if they have no ingredients
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchTerm = value.toLowerCase();
                      // Filter ingredients based on name or alias
                      filteredIngredients = allIngredients.where((ingredient) {
                        return ingredient.name.toLowerCase().contains(searchTerm) ||
                            (ingredient.alias != null &&
                                ingredient.alias!.toLowerCase().contains(searchTerm));
                      }).toList();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Ingredients',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: categories.map((category) {
                    final categoryIngredients = groupedIngredients[category.id] ?? [];
                    // Filter category ingredients based on the search term
                    final filteredCategoryIngredients = categoryIngredients.where((ingredient) {
                      return filteredIngredients.contains(ingredient);
                    }).toList();

                    return IngredientCategoryWidget(
                      category: category,
                      ingredients: filteredCategoryIngredients,
                      onIngredientToggle: (ingredient) {
                        print('${ingredient.name} toggled: ${ingredient.isSelected}');
                      },
                      onEssentialToggle: (ingredient) {
                        print('${ingredient.name} is now essential: ${ingredient.isEssential}');
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}