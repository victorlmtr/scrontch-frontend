import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../models/recipe.dart';
import '../models/recipe_item.dart';
import '../models/recipe_list.dart';
import 'recipe_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeListScreen extends StatefulWidget {
  final int userId;

  const RecipeListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late Future<List<RecipeList>> recipeLists;
  final ApiService _apiService = ApiService();
  Map<int, bool> checkedRecipes = {};
  Map<int, String> recipeNames = {};
  String get _checkedRecipesKey => 'checked_recipes_${widget.userId}';

  @override
  void initState() {
    super.initState();
    recipeLists = fetchRecipeLists(widget.userId);
    _loadCheckedRecipes();
  }

  Future<List<RecipeList>> fetchRecipeLists(int userId) async {
    final response = await http.get(
      Uri.parse('https://victorl.xyz:8085/api/v1/recipelists/user/$userId'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RecipeList.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipe lists');
    }
  }

  Future<void> _saveCheckedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final checkedItems = Map<String, bool>.from(
      checkedRecipes.map((key, value) => MapEntry(key.toString(), value)),
    );
    await prefs.setString(_checkedRecipesKey, jsonEncode(checkedItems));
  }

  Future<void> _loadCheckedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString(_checkedRecipesKey);
    if (savedData != null) {
      final Map<String, dynamic> checkedItems = jsonDecode(savedData);
      setState(() {
        checkedRecipes.addAll(
          checkedItems.map((key, value) => MapEntry(int.parse(key), value as bool)),
        );
      });
    }
  }

  Future<void> _showAddLinkDialog(RecipeItem item) async {
    final TextEditingController linkController = TextEditingController(text: item.recipeLink ?? '');

    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add/Edit Recipe Link'),
          content: TextField(
            controller: linkController,
            decoration: const InputDecoration(hintText: 'Enter recipe link'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, linkController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      // Save the recipe link to the server or local state
      setState(() {
        item.recipeLink = result;
      });

      // Optionally save to the server
      await _saveRecipeLink(item.id, result);
    }
  }

  Future<void> _saveRecipeLink(int itemId, String link) async {
    // Implement the API call to save the recipe link
    final response = await http.put(
      Uri.parse('https://victorl.xyz:8085/api/v1/recipeitems/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'recipeLink': link}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save recipe link');
    }
  }

  Future<String> getRecipeName(int recipeId) async {
    if (recipeNames.containsKey(recipeId)) {
      return recipeNames[recipeId]!;
    }
    try {
      final response = await http.get(
        Uri.parse('https://victorl.xyz:8084/api/v1/recipes/$recipeId'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final recipeName = data['name'] ?? 'Unknown';
        setState(() {
          recipeNames[recipeId] = recipeName;
        });
        return recipeName;
      } else {
        throw Exception('Failed to load recipe name');
      }
    } catch (e) {
      print('Error fetching recipe name: $e');
      return 'Unknown';
    }
  }

  void _handleCheckboxChanged(int recipeItemId, bool? value) {
    if (value == null) return;

    setState(() {
      checkedRecipes[recipeItemId] = value;
    });

    _saveCheckedRecipes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe List'),
      ),
      body: FutureBuilder<List<RecipeList>>(
        future: recipeLists,
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
                                Text('Recipes', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                ...list.recipeItems.map((item) => FutureBuilder<String>(
                                  future: item.recipeId != null
                                      ? getRecipeName(item.recipeId!)
                                      : Future.value(item.recipeName ?? 'Unknown'),
                                  builder: (context, snapshot) {
                                    final recipeName = snapshot.data ?? 'Loading...';
                                    return Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: checkedRecipes[item.id] ?? false,
                                              onChanged: (bool? value) {
                                                _handleCheckboxChanged(item.id, value);
                                              },
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: item.recipeId != null
                                                    ? () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => RecipeDetailScreen(
                                                        recipeId: item.recipeId!,
                                                        userId: widget.userId,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                    : null,
                                                child: Text(recipeName),
                                              ),
                                            ),
                                            if (item.recipeLink?.isNotEmpty ?? false)
                                              IconButton(
                                                icon: const Icon(Icons.link),
                                                onPressed: () async {
                                                  final url = item.recipeLink!;
                                                  if (await canLaunch(url)) {
                                                    await launch(url);
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                },
                                              ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                _showAddLinkDialog(item);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )).toList(),
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
            return const Center(child: Text('No recipe lists available'));
          }
        },
      ),
    );
  }
}