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
      setState(() {
        pantryIngredients = pantry;
        // Set isSelected for all ingredients based on pantry data
        for (var ingredient in allIngredients) {
          ingredient.isSelected = pantryIngredients.any((p) => p.id == ingredient.id);
        }
      });
    } catch (error) {
      print('Error loading pantry: $error');
    }
  }

    void _toggleIngredient(Ingredient ingredient) async {
      try {
        // Update local state first
        setState(() {
          ingredient.isSelected = !ingredient.isSelected;
        });

        if (ingredient.isSelected) {
          // Check if the ingredient is already in the pantry (i.e., it should not be added again)
          bool existsInPantry = pantryIngredients.any((p) => p.id == ingredient.id);
          if (!existsInPantry) {
            // If it doesn't exist in pantry, add it
            await apiService.addUserIngredient(ingredient.id, currentUserId);
            print('Ingredient added to pantry');
          } else {
            // Ingredient is already in pantry
            print('Ingredient already in pantry, no need to add');
          }
        } else {
          // Only try to remove if it exists in the pantry
          bool existsInPantry = pantryIngredients.any((p) => p.id == ingredient.id);
          if (existsInPantry) {
            // Remove ingredient if it exists in the pantry
            await apiService.removeUserIngredient(ingredient.id, currentUserId);
            print('Ingredient removed from pantry');
          } else {
            // Ingredient not found in pantry, cannot remove
            setState(() {
              ingredient.isSelected = true; // Revert the toggle if not found
            });
            print('Ingredient not found in pantry, cannot remove.');
          }
        }
        print('Ingredient toggled successfully');
      } catch (error) {
        // Rollback state on failure
        setState(() {
          ingredient.isSelected = !ingredient.isSelected; // Revert the toggle
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
                            (ingredient.alias.toLowerCase().contains(
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