import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../api/api_service.dart';
import '../models/ingredient_category.dart';
import '../widgets/ingredient_category_widget.dart';

class PantryContentScreen extends StatefulWidget {
  @override
  _PantryContentScreenState createState() => _PantryContentScreenState();
}

class _PantryContentScreenState extends State<PantryContentScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> futureData;
  int currentUserId = 18;
  List<Ingredient> pantryIngredients = [];
  List<Ingredient> allIngredients = [];
  List<IngredientCategory> categories = [];
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    futureData = Future.wait([
      apiService.fetchIngredients(),
      apiService.fetchCategories(),
    ]);
    _loadUserPantry();
  }

  void _loadUserPantry() async {
    try {
      final pantry = await apiService.fetchUserPantry(currentUserId);
      print('Pantry data: $pantry');
      if (pantry != null) {
        setState(() {
          pantryIngredients = pantry;
        });
      } else {
        print('Pantry data is null');
      }
    } catch (error) {
      print('Error loading pantry: $error');
    }
  }

  void _toggleIngredient(Ingredient ingredient) async {
    try {
      // Update the local state first
      setState(() {
        ingredient.isSelected = !ingredient.isSelected;
      });

      // Make API call to toggle user-specific ingredient state
      await apiService.addUserIngredient(ingredient.id, currentUserId);

      // Log for debugging
      print('Ingredient toggled successfully');
    } catch (error) {
      // Rollback state on failure
      setState(() {
        ingredient.isSelected = !ingredient.isSelected;
      });
      print('Error toggling ingredient: $error');
    }
  }

  void _markEssential(Ingredient ingredient) async {
    try {
      // Update the local state first
      setState(() {
        ingredient.isEssential = !ingredient.isEssential;
      });

      // Make API call to mark ingredient as essential
      await apiService.markEssentialIngredient(ingredient.id, currentUserId);

      // Log for debugging
      print('Ingredient marked as essential successfully');
    } catch (error) {
      // Rollback state on failure
      setState(() {
        ingredient.isEssential = !ingredient.isEssential;
      });
      print('Error marking essential: $error');
    }
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
            categories = (snapshot.data![1] as List<dynamic>)
                .map((json) => IngredientCategory.fromJson(json))
                .toList();

            allIngredients = ingredients;
            final groupedIngredients = <int, List<Ingredient>>{};
            for (var ingredient in ingredients) {
              groupedIngredients.putIfAbsent(ingredient.categoryId, () => [])
                  .add(ingredient);
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Rechercher un ingrédient',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: categories.map((category) {
                      final categoryIngredients = groupedIngredients[category
                          .id] ?? [];
                      final filteredCategoryIngredients = categoryIngredients
                          .where((ingredient) {
                        return ingredient.name.toLowerCase().contains(
                            searchTerm) ||
                            (ingredient.alias != null &&
                                ingredient.alias!.toLowerCase().contains(
                                    searchTerm));
                      }).toList();
                      if (filteredCategoryIngredients.isNotEmpty ||
                          searchTerm.isEmpty) {
                        return IngredientCategoryWidget(
                          category: category,
                          ingredients: filteredCategoryIngredients,
                          onIngredientToggle: (ingredient) {
                            _toggleIngredient(ingredient);
                          },
                          onEssentialToggle: (ingredient) {
                            _markEssential(ingredient);
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }).toList(),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        });
  }
}