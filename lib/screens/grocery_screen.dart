import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _searchController = TextEditingController();
  late Future<List<ShoppingList>> shoppingLists;
  final ApiService _apiService = ApiService();
  List<Ingredient> allIngredients = [];
  TextEditingController searchController = TextEditingController();
  String searchTerm = '';
  late Future<List<dynamic>> futureData;
  Map<int, bool> checkedIngredients = {};
  String get _checkedIngredientsKey => 'checked_ingredients_${widget.userId}';
  String _getListSpecificKey(int listId) => '${_checkedIngredientsKey}_$listId';
  bool showCheckedItems = false;
  Map<int, bool> checkedNonFoodItems = {};
  String get _checkedNonFoodItemsKey => 'checked_nonfood_${widget.userId}';
  String _getListSpecificNonFoodKey(int listId) => '${_checkedNonFoodItemsKey}_$listId';
  Map<int, TextEditingController> _descriptionControllers = {};

  Future<void> _saveCheckedIngredients(int listId) async {
    final prefs = await SharedPreferences.getInstance();
    final checkedItemsForList = Map<String, bool>.from(
        checkedIngredients.map((key, value) => MapEntry(key.toString(), value))
    );
    await prefs.setString(_getListSpecificKey(listId), jsonEncode(checkedItemsForList));
  }

  Future<void> _handleEssentialIngredients() async {
    try {
      // Wait for ingredients to load first
      if (allIngredients.isEmpty) {
        await _loadIngredients();
      }

      final essentialIngredients = await _apiService.fetchEssentialIngredients(widget.userId);
      final pantryIngredients = await _apiService.fetchUserPantry(widget.userId);

      // Find essential ingredients not in pantry
      final missingEssentials = essentialIngredients.where((essential) =>
      !pantryIngredients.any((pantry) => pantry.id == essential.id)
      ).toList();

      if (missingEssentials.isEmpty) {
        return;
      }

      // Get or create first shopping list
      List<ShoppingList> lists = await fetchShoppingLists(widget.userId);
      ShoppingList? firstList;

      if (lists.isEmpty) {
        // Create new list
        final newList = ShoppingList(
          userId: widget.userId,
          name: 'Liste principale',
          ingredientItems: [],
          nonFoodItems: [],
        );

        final response = await http.post(
          Uri.parse('https://victorl.xyz:8085/api/v1/shoppinglists'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newList.toJson()),
        );

        if (response.statusCode == 201) {
          firstList = ShoppingList.fromJson(jsonDecode(response.body));
          lists = [firstList]; // Update lists with the new list
        } else {
          throw Exception('Failed to create shopping list');
        }
      } else {
        firstList = lists.first;
      }

      if (firstList?.id == null) {
        throw Exception('Invalid shopping list ID');
      }

      for (var ingredient in missingEssentials) {
        if (!firstList!.ingredientItems.any((item) => item.ingredientId == ingredient.id)) {
          await _addIngredientItem(firstList!, ingredient.id);
        }
      }

      setState(() {
        shoppingLists = fetchShoppingLists(widget.userId);
      });
    } catch (e) {
      print('Error handling essential ingredients: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout des articles essentiels: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCheckedIngredients(int listId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_getListSpecificKey(listId));
      if (savedData != null) {
        final Map<String, dynamic> checkedItems = jsonDecode(savedData);
        setState(() {
          checkedIngredients.addAll(
              checkedItems.map((key, value) => MapEntry(int.parse(key), value as bool))
          );
        });
      }
    } catch (e) {
      print('Error loading checked ingredients: $e');
    }
  }

  Future<void> _saveCheckedNonFoodItems(int listId) async {
    final prefs = await SharedPreferences.getInstance();
    final checkedItemsForList = Map<String, bool>.from(
        checkedNonFoodItems.map((key, value) => MapEntry(key.toString(), value))
    );
    await prefs.setString(_getListSpecificNonFoodKey(listId), jsonEncode(checkedItemsForList));
  }

  Future<void> _loadCheckedNonFoodItems(int listId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_getListSpecificNonFoodKey(listId));
      if (savedData != null) {
        final Map<String, dynamic> checkedItems = jsonDecode(savedData);
        setState(() {
          checkedNonFoodItems.addAll(
              checkedItems.map((key, value) => MapEntry(int.parse(key), value as bool))
          );
        });
      }
    } catch (e) {
      print('Error loading checked non-food items: $e');
    }
  }

  Future<void> _handleNonFoodCheckboxChanged(int itemId, bool? value, ShoppingList list) async {
    if (value == null || list.id == null) return;

    setState(() {
      checkedNonFoodItems[itemId] = value;
    });

    await _saveCheckedNonFoodItems(list.id!);
  }



  Future<void> _handleCheckboxChanged(int itemId, bool? value, ShoppingList list) async {
    if (value == null || list.id == null) return;

    setState(() {
      checkedIngredients[itemId] = value;
    });

    await _saveCheckedIngredients(list.id!);

    if (value) {
      try {
        final ingredient = list.ingredientItems.firstWhere((item) => item.id == itemId);
        await _apiService.addUserIngredient(ingredient.ingredientId, widget.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingredient added to pantry')),
          );
        }
      } catch (e) {
        setState(() {
          checkedIngredients[itemId] = false;
        });
        await _saveCheckedIngredients(list.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add to pantry: $e')),
          );
        }
      }
    } else {
      try {
        final ingredient = list.ingredientItems.firstWhere((item) => item.id == itemId);
        await _apiService.removeUserIngredient(ingredient.ingredientId, widget.userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingredient removed from pantry')),
          );
        }
      } catch (e) {
        setState(() {
          checkedIngredients[itemId] = true;
        });
        await _saveCheckedIngredients(list.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove from pantry: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateIngredientItemDescription(int itemId, int? shoppingListId, String description) async {
    if (shoppingListId == null) {
      throw Exception('Invalid shopping list ID');
    }

    final response = await http.put(
      Uri.parse('https://victorl.xyz:8085/api/v1/ingredientitems/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ingredientId': itemId,
        'ingredientItemDescription': description,
        'shoppingListId': shoppingListId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update description');
    }
  }

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
  void dispose() {
    _descriptionControllers.values.forEach((controller) => controller.dispose());
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      shoppingLists = fetchShoppingLists(widget.userId);
      futureData = _apiService.fetchIngredients();
      await _loadIngredients();
      await _initializeListData();
      await _handleEssentialIngredients();
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  Future<void> _initializeListData() async {
    try {
      final lists = await shoppingLists;
      for (var list in lists) {
        if (list.id != null) {
          await _loadCheckedIngredients(list.id!);
          await _loadCheckedNonFoodItems(list.id!);
        }
      }
    } catch (e) {
      print('Error initializing list data: $e');
    }
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await futureData;
      setState(() {
        allIngredients = ingredients.map((json) => Ingredient.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading ingredients: $e');
    }
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

  Future<void> _clearCheckedItems(ShoppingList list) async {
    if (list.id == null) return;
    final checkedItemsInList = list.ingredientItems
        .where((item) => checkedIngredients[item.id] ?? false)
        .toList();

    for (var item in checkedItemsInList) {
      try {
        await _deleteIngredientItem(item.id, list.id);
      } catch (e) {
        print('Error removing ingredient from pantry: $e');
      }
    }

    setState(() {
      for (var item in checkedItemsInList) {
        checkedIngredients.remove(item.id);
      }
    });
    await _saveCheckedIngredients(list.id!);

    setState(() {
      shoppingLists = fetchShoppingLists(widget.userId);
    });
  }

  Future<void> _clearCheckedNonFoodItems(ShoppingList list) async {
    if (list.id == null) return;

    final checkedItemsInList = list.nonFoodItems
        .where((item) => checkedNonFoodItems[item.id] ?? false)
        .toList();

    for (var item in checkedItemsInList) {
      try {
        await _deleteNonFoodItem(item.id, list.id);
      } catch (e) {
        print('Error removing non-food item: $e');
      }
    }

    setState(() {
      for (var item in checkedItemsInList) {
        checkedNonFoodItems.remove(item.id);
      }
    });

    await _saveCheckedNonFoodItems(list.id!);

    setState(() {
      shoppingLists = fetchShoppingLists(widget.userId);
    });
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

  Future<void> _addIngredientItem(ShoppingList list, int ingredientId) async {
    final listId = list.id;
    if (listId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid shopping list ID')),
        );
      }
      return;
    }

    if (list.ingredientItems.any((item) => item.ingredientId == ingredientId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cet ingrédient est déjà dans la liste')),
        );
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://victorl.xyz:8085/api/v1/shoppinglists/$listId/ingredientitems'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ingredientid': ingredientId,
          'ingredientitemdescription': '',
          'shoppinglistid': listId,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          shoppingLists = fetchShoppingLists(widget.userId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrédient ajouté avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout de l\'ingrédient: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteIngredientItem(int itemId, int? shoppingListId) async {
    if (shoppingListId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid shopping list ID')),
        );
      }
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('https://victorl.xyz:8085/api/v1/ingredientitems/$itemId'),
      );

      if (response.statusCode == 204) {
        setState(() {
          checkedIngredients.remove(itemId);
          shoppingLists = fetchShoppingLists(widget.userId);
        });
        await _saveCheckedIngredients(shoppingListId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingrédient supprimé avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression de l\'ingrédient: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addNonFoodItem(ShoppingList list, String name, String description) async {
    final listId = list.id;
    if (listId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid shopping list ID')),
        );
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://victorl.xyz:8085/api/v1/shoppinglists/$listId/nonfooditems'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nonfooditemname': name,
          'nonfooditemdescription': description,
          'shoppinglistid': listId,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          shoppingLists = fetchShoppingLists(widget.userId);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article non-alimentaire ajouté avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout de l\'article non-alimentaire: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteNonFoodItem(int itemId, int? shoppingListId) async {
    if (shoppingListId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid shopping list ID')),
        );
      }
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('https://victorl.xyz:8085/api/v1/nonfooditems/$itemId'),
      );

      if (response.statusCode == 204) {
        setState(() {
          checkedNonFoodItems.remove(itemId);
          shoppingLists = fetchShoppingLists(widget.userId);
        });
        await _saveCheckedNonFoodItems(shoppingListId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article non-alimentaire supprimé avec succès')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression de l\'article non-alimentaire: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearSearch() {
    setState(() {
      searchTerm = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Rechercher un ingrédient à ajouter',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  // Search Results
                  if (searchTerm.isNotEmpty)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Builder(
                        builder: (context) {
                          final currentList = snapshot.data![DefaultTabController.of(context)?.index ?? 0];
                          final filteredIngredients = allIngredients
                              .where((ingredient) =>
                          ingredient.name.toLowerCase().contains(searchTerm) ||
                              ingredient.alias.toLowerCase().contains(searchTerm))
                              .toList();

                          return ListView.builder(
                            itemCount: filteredIngredients.length,
                            itemBuilder: (context, index) {
                              final ingredient = filteredIngredients[index];
                              return ListTile(
                                title: Text(ingredient.name),
                                subtitle: ingredient.alias.isNotEmpty ? Text(ingredient.alias) : null,
                                onTap: () {
                                  _addIngredientItem(currentList, ingredient.id);
                                  _clearSearch();
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  // Tab Bar
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.black,
                    tabs: snapshot.data!.map((list) {
                      return Tab(text: list.name);
                    }).toList(),
                  ),
                  // Tab View Content
                  Expanded(
                    child: TabBarView(
                      children: snapshot.data!.map((list) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ingrédients', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                ...list.ingredientItems
                                    .where((item) => !(checkedIngredients[item.id] ?? false))
                                    .map((item) => FutureBuilder<String>(
                                  future: getIngredientName(item.ingredientId),
                                  builder: (context, snapshot) {
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child:
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: checkedIngredients[item.id] ?? false,
                                              onChanged: (bool? value) {
                                                _handleCheckboxChanged(item.id, value, list);
                                              },
                                            ),
                                            Expanded(
                                              child: Text(snapshot.data ?? 'Loading...'),
                                            ),
                                            if (item.description?.isNotEmpty ?? false)
                                            // Show description as text if it exists
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  item.description!,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              )
                                            else
                                            // Show small icon button if no description
                                              IconButton(
                                                icon: const Icon(Icons.edit_note, size: 16),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                onPressed: () async {
                                                  final controller = TextEditingController(text: item.description);
                                                  final description = await showDialog<String>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: const Text('Modifier la description'),
                                                      content: TextField(
                                                        controller: controller,
                                                        decoration: const InputDecoration(
                                                          hintText: 'Description',
                                                        ),
                                                        maxLines: null,
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Annuler'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context, controller.text),
                                                          child: const Text('Enregistrer'),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (description != null) {
                                                    try {
                                                      await _updateIngredientItemDescription(item.id, list.id, description);
                                                      setState(() {
                                                        shoppingLists = fetchShoppingLists(widget.userId);
                                                      });
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text('Description mise à jour')),
                                                        );
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Erreur lors de la mise à jour: $e'),
                                                            backgroundColor: Colors.red,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  }
                                                  controller.dispose();
                                                },
                                              ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              onPressed: () {
                                                _deleteIngredientItem(item.id, list.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ))
                                    .toList(),
                                ExpansionTile(
                                  title: Row(
                                    children: [
                                      Flexible(
                                        child: const Text(
                                          'Ingrédients cochés',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _clearCheckedItems(list),
                                        child: const Text('Vider la liste'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 8), // Reduce padding
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: list.ingredientItems
                                      .where((item) => checkedIngredients[item.id] ?? false)
                                      .map((item) => FutureBuilder<String>(
                                    future: getIngredientName(item.ingredientId),
                                    builder: (context, snapshot) {
                                      return Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                            Checkbox(
                                            value: true,
                                            onChanged: (bool? value) {
                                              _handleCheckboxChanged(item.id, value, list);
                                            },
                                          ),
                                            Expanded(
                                              child: Text(
                                                snapshot.data ?? 'Loading...',
                                                style: const TextStyle(
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ),
                                            if (item.description?.isNotEmpty ?? false)
                                        Text(
                                        item.description!,
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ))
                                      .toList(),
                                ),

                                // Add Ingredient Button
                                TextButton.icon(
                                  onPressed: () => _showIngredientSearch(list),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ajouter un ingrédient'),
                                ),

                                // Non-Food Items Section
                                const Divider(height: 32),
                                Text('Articles non-alimentaires',
                                    style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                ...list.nonFoodItems
                                    .where((item) => !(checkedNonFoodItems[item.id] ?? false))
                                    .map((item) => Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: checkedNonFoodItems[item.id] ?? false,
                                          onChanged: (bool? value) {
                                            _handleNonFoodCheckboxChanged(item.id, value, list);
                                          },
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller: TextEditingController(text: item.name),
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
                                            controller: TextEditingController(text: item.description),
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
                                            _deleteNonFoodItem(item.id, list.id);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                                    .toList(),
                                ExpansionTile(
                                  title: Row(
                                    children: [
                                      const Flexible(
                                        child: Text(
                                          'Checked non-food items',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => _clearCheckedNonFoodItems(list),
                                        child: const Text('Clear non-food'),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: list.nonFoodItems
                                      .where((item) => checkedNonFoodItems[item.id] ?? false)
                                      .map((item) => Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: true,
                                            onChanged: (bool? value) {
                                              _handleNonFoodCheckboxChanged(item.id, value, list);
                                            },
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.name,
                                              style: const TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              item.description ?? '',
                                              style: const TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    // Show dialog to add non-food item
                                    _showAddNonFoodItemDialog(list);
                                  },
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

  void _showAddNonFoodItemDialog(ShoppingList list) {
    String name = '';
    String description = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un article non-alimentaire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'article',
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _addNonFoodItem(list, name, description);
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
