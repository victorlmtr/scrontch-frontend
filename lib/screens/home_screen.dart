import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:scrontch_flutter/screens/recipe_detail_screen.dart';
import 'package:scrontch_flutter/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../api/diet_service.dart';
import '../api/secure_storage_service.dart';
import '../models/country.dart';
import '../models/recipe.dart';
import '../models/recipe_diet.dart';
import '../models/recipe_type.dart';
import '../models/step.dart';
import '../widgets/home_header_card.dart';
import '../widgets/recipe_big_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _secureStorageService = SecureStorageService();
  late final ApiService _apiService;
  late final DietService _dietService;
  bool _isLoggedIn = false;
  String _username = '';
  bool _isLoginDialogShown = false;
  List<Recipe> _recipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _dietService = DietService(_apiService);
    _checkLoginStatus();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://victorl.xyz:8084/api/v1/recipes'),
        headers: {'Accept-Charset': 'UTF-8'},
      );

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> recipesJson = json.decode(decodedBody);

        final recipes = recipesJson.map((json) {
          try {
            final recipeType = RecipeType.fromJson(json['typeid'] ?? {});
            final countries = (json['countries'] as List?)
                ?.map((country) => Country.fromJson(country))
                .toList() ?? [];
            final recipeDiets = (json['recipediets'] as List?)
                ?.map((diet) => RecipeDiet.fromJson(diet))
                .toList() ?? [];
            final steps = (json['steps'] as List?)
                ?.map((step) => RecipeStep.fromJson(step))
                .toList() ?? [];

            return Recipe(
              id: json['id'] ?? 0,
              name: json['name'] ?? '',
              description: json['description'] ?? '',
              difficulty: json['difficulty'] ?? 0,
              portions: (json['portions'] ?? 0.0).toDouble(),
              notes: json['notes'],
              image: json['image'],
              createdAt: json['createdat'] != null
                  ? DateTime.parse(json['createdat'])
                  : DateTime.now(),
              updatedAt: json['updatedat'] != null
                  ? DateTime.parse(json['updatedat'])
                  : null,
              type: recipeType,
              countries: countries,
              recipeDiets: recipeDiets,
              recipeSteps: steps,
              formattedTotalTime: json['formattedTotalTime'] ?? '',
            );
          } catch (e, stackTrace) {
            print('Error parsing recipe: $e\n$stackTrace');
            rethrow;
          }
        }).toList();

        setState(() {
          _recipes = recipes;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading recipes: $e\n$stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    String? token;
    String? refreshToken;
    String? username;
    int? userId;
    String? role;

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      refreshToken = prefs.getString('refreshToken');
      username = prefs.getString('username');
      userId = prefs.getInt('userId');
      role = prefs.getString('role');
      _isLoginDialogShown = prefs.getBool('isLoginDialogShown') ?? false;
    } else {
      token = await _secureStorageService.read('token');
      refreshToken = await _secureStorageService.read('refreshToken');
      username = await _secureStorageService.read('username');
      userId = int.tryParse(await _secureStorageService.read('userId') ?? '');
      role = await _secureStorageService.read('role');
    }

    // Refresh token if necessary
    if (token == null || token.isEmpty) {
      token = await _refreshToken(refreshToken);
    }

    setState(() {
      _isLoggedIn = token != null;
      _username = username ?? '';
    });

    if (!_isLoggedIn && !_isLoginDialogShown) {
      Future.delayed(Duration.zero, () {
        _showLoginDialog(context);
      });
    }
  }

  Future<void> _saveLoginInfo(String token, String username, int userId, String role) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      await prefs.setInt('userId', userId);
      await prefs.setString('role', role);
    } else {
      await _secureStorageService.save('token', token);
      await _secureStorageService.save('username', username);
      await _secureStorageService.save('userId', userId.toString());
      await _secureStorageService.save('role', role);
    }
  }

  Future<void> _updateRecipeDiets(Recipe recipe) async {
    if (recipe.recipeDiets.isNotEmpty) {
      await _dietService.updateRecipeDietsWithNames(recipe.recipeDiets);
    }
  }

  Future<void> _markLoginDialogAsShown() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoginDialogShown', true);
    }
  }

  void _showLoginDialog(BuildContext context) {
    String username = '';
    String password = '';
    bool _passwordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Se connecter'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(labelText: 'Pseudo ou e-mail'),
                      onChanged: (value) {
                        username = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Se connecter'),
                  onPressed: () async {
                    bool success = await _login(context, username, password);

                    if (success) {
                      Navigator.of(context).pop();
                      _markLoginDialogAsShown();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connexion échouée. Veuillez réessayer.')),
                      );
                    }
                  },
                ),
                TextButton(
                  child: const Text('Mot de passe oublié ?'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Créer un compte'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Se déconnecter'),
              onPressed: () async {
                await _logout();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    const String apiUrl = 'https://victorl.xyz:8086/api/v1/auth/logout';

    try {
      String? token = await _secureStorageService.read('token');
      if (token == null || token.isEmpty) {
        print('No token found. Cannot logout.');
        return;
      }

      print('Token: $token');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
        } else {
          await _secureStorageService.delete('token');
          await _secureStorageService.delete('username');
          await _secureStorageService.delete('userId');
          await _secureStorageService.delete('role');
        }

        setState(() {
          _isLoggedIn = false;
          _username = '';
        });
      } else {
        print('Failed to logout. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while logging out: $e');
    }
  }


  Future<bool> _login(BuildContext context, String username, String password) async {
    const String apiUrl = 'https://victorl.xyz:8086/api/v1/auth/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveLoginInfo(data['token'], data['username'], data['userid'], data['role']);
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('refreshToken', data['refreshToken']);
        } else {
          await _secureStorageService.save('refreshToken', data['refreshToken']);
        }

        setState(() {
          _isLoggedIn = true;
          _username = data['username'];
        });

        return true;
      } else {
        print('Failed to login. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred while logging in: $e');
      return false;
    }
  }


  Future<String?> _refreshToken(String? refreshToken) async {
    const String apiUrl = 'https://victorl.xyz:8086/api/v1/auth/refresh-token';

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String newToken = data['accessToken'];
        String newRefreshToken = data['refreshToken'];

        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);
          await prefs.setString('refreshToken', newRefreshToken);
        } else {
          await _secureStorageService.save('token', newToken);
          await _secureStorageService.save('refreshToken', newRefreshToken);
        }

        return newToken;
      } else {
        print('Failed to refresh token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred while refreshing token: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadRecipes,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _recipes.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return HomeHeaderCard(
                isLoggedIn: _isLoggedIn,
                username: _username,
                onSearch: (query) {
                  print('Search query: $query');
                },
              onProfileTap: () {
                if (_isLoggedIn) {
                  _showLogoutDialog(context);
                } else {
                  _showLoginDialog(context);
                  }
                },
              );
            }
            final recipe = _recipes[index - 1];
            return FutureBuilder(
              future: _updateRecipeDiets(recipe),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RecipeBigCard(
                  recipeName: recipe.name,
                  imageRes: recipe.image,
                  chipLabel1: recipe.type.typeName,
                  chipLabel2: recipe.recipeDiets.isNotEmpty
                      ? recipe.recipeDiets.first.dietName ?? ''
                      : '',
                  chipLabel3: recipe.countries.isNotEmpty
                      ? recipe.countries.first.name
                      : '',
                  chipIcon1: recipe.type.typeIcon ?? '',
                  chipIcon2: recipe.recipeDiets.isNotEmpty
                      ? recipe.recipeDiets.first.dietIcon ?? ''
                      : '',
                  recipeLength: recipe.formattedTotalTime,
                  userCount: 21,
                  rating: 3.5,
                  badgeCount: 6,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          recipeId: recipe.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _isLoggedIn
          ? FloatingActionButton(
        onPressed: () {
          // Navigate to create recipe screen
          // To be implemented
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
