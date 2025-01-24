import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../api/api_service.dart';
import '../models/ingredient.dart';
import '../models/shopping_list.dart';

class GroceryScreen extends StatefulWidget {
  final int userId;

  GroceryScreen({required this.userId});

  @override
  _GroceryScreenState createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  late Future<List<ShoppingList>> shoppingLists;
  final ApiService _apiService = ApiService();
  List<Ingredient> allIngredients = [];
  TextEditingController searchController = TextEditingController();

  // Add these helper methods to fetch ingredient name
  Future<String> getIngredientName(int ingredientId) async {
    if (allIngredients.isEmpty) {
      final ingredients = await _apiService.fetchIngredients();
      allIngredients =
          ingredients.map((json) => Ingredient.fromJson(json)).toList();
    }
    final ingredient = allIngredients.firstWhere(
          (i) => i.id == ingredientId,
      orElse: () =>
          Ingredient(
            id: ingredientId,
            name: 'Unknown',
            alias: '',
            image: '',
            description: '',
            categoryId: 0,
            isSelected: false,
            isEssential: false,
          ),
    );
    return ingredient.name;
  }

  @override
  void initState() {
    super.initState();
    shoppingLists = fetchShoppingLists(widget.userId);
  }

  Future<List<ShoppingList>> fetchShoppingLists(int userId) async {
    final response = await http.get(
        Uri.parse('https://victorl.xyz:8085/api/v1/shoppinglists/user/$userId'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ShoppingList.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shopping lists');
    }
  }

  Future<void> createNewShoppingList() async {
    String? listName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String newListName = "Nouvelle liste";
        return AlertDialog(
          title: const Text('New Shopping List'),
          content: TextField(
            onChanged: (value) {
              newListName = value;
            },
            decoration: const InputDecoration(
              hintText: 'Enter list name',
            ),
            controller: TextEditingController(text: newListName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, newListName),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (listName == null || listName.isEmpty) return;

    try {
      final newList = ShoppingList(
        userId: widget.userId,
        name: listName,
        ingredientItems: [],
        nonFoodItems: [],
      );

      final response = await http.post(
        Uri.parse('https://victorl.xyz:8085/api/v1/shoppinglists'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newList.toJson()),
      );

      if (response.statusCode == 201) {
        setState(() {
          shoppingLists = fetchShoppingLists(widget.userId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shopping list created successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create shopping list: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Lists'),
      ),
      body: FutureBuilder<List<ShoppingList>>(
        future: shoppingLists,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return DefaultTabController(
              length: snapshot.data!.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                    tabs: snapshot.data!.map((list) {
                      return Tab(text: list.name);
                    }).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: snapshot.data!.map((list) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ingredient Items Section
                                Text('Ingrédients', style: Theme
                                    .of(context)
                                    .textTheme
                                    .titleLarge),
                                const SizedBox(height: 8),
                                ...list.ingredientItems.map((item) =>
                                    FutureBuilder<String>(
                                      future: getIngredientName(
                                          item.ingredientId),
                                      builder: (context, snapshot) {
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Checkbox(
                                                  value: false,
                                                  // Add a checked property to IngredientItem if needed
                                                  onChanged: (bool? value) {
                                                    // Handle checkbox state
                                                  },
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(snapshot.data ??
                                                      'Loading...'),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: TextField(
                                                    controller: TextEditingController(
                                                        text: item.description),
                                                    decoration: const InputDecoration(
                                                      hintText: 'Description (quantité, marque...)',
                                                    ),
                                                    onChanged: (value) {
                                                      // Update description
                                                    },
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.delete),
                                                  onPressed: () {
                                                    // Handle delete
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )).toList(),

                                // Add Ingredient Button
                                TextButton.icon(
                                  onPressed: () => _showIngredientSearch(list),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter un ingrédient'),
                                ),

                                const Divider(height: 32),

                                // Non-Food Items Section
                                Text('Articles non-alimentaires',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .titleLarge),
                                const SizedBox(height: 8),
                                ...list.nonFoodItems.map((item) =>
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: false,
                                              // Add a checked property to NonFoodItem if needed
                                              onChanged: (bool? value) {
                                                // Handle checkbox state
                                              },
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: TextField(
                                                controller: TextEditingController(
                                                    text: item.name),
                                                decoration: const InputDecoration(
                                                  hintText: 'Nom de l\'article',
                                                ),
                                                onChanged: (value) {
                                                  // Update name
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                controller: TextEditingController(
                                                    text: item.description),
                                                decoration: const InputDecoration(
                                                  hintText: 'Description',
                                                ),
                                                onChanged: (value) {
                                                  // Update description
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () {
                                                // Handle delete
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )).toList(),

                                // Add Non-Food Item Button
                                TextButton.icon(
                                  onPressed: () => _addNonFoodItem(list),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter un article'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No shopping lists available'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewShoppingList,
        child: const Icon(Icons.add),
        tooltip: 'Create New Shopping List',
      ),
    );
  }

  void _addIngredientItem(ShoppingList list, int ingredientId) {
    // Add API call to create new ingredient item
    // Update the UI after successful creation
    setState(() {
      shoppingLists = fetchShoppingLists(widget.userId);
    });
  }

  void _addNonFoodItem(ShoppingList list) {
    // Add API call to create new non-food item
    // Update the UI after successful creation
    setState(() {
      shoppingLists = fetchShoppingLists(widget.userId);
    });
  }

  void _showIngredientSearch(ShoppingList list) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rechercher un ingrédient'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Nom de l\'ingrédient',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: ListView(
                      children: allIngredients
                          .where((ingredient) =>
                          ingredient.name
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase()))
                          .map((ingredient) =>
                          ListTile(
                            title: Text(ingredient.name),
                            onTap: () {
                              _addIngredientItem(list, ingredient.id);
                              Navigator.pop(context);
                            },
                          ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


