import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../models/ingredient.dart';
import '../models/shopping_list.dart';

final TextEditingController _searchController = TextEditingController();
late Future<List<ShoppingList>> shoppingLists;
final ApiService _apiService = ApiService();
List<Ingredient> allIngredients = [];
TextEditingController searchController = TextEditingController();
String searchTerm = '';
late Future<List<dynamic>> futureData;
Map<int, bool> checkedIngredients = {};
bool showCheckedItems = false;
Map<int, bool> checkedNonFoodItems = {};




