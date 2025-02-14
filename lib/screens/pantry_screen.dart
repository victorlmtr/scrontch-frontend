import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrontch_flutter/screens/recipe_list_screen.dart';
import '../widgets/screen_picker.dart';
import 'grocery_screen.dart';
import 'pantry_content_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/secure_storage_service.dart';

class PantryScreen extends StatefulWidget {
  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _selectedScreen = "Garde-manger";
  final List<String> _screenOptions = ["Garde-manger", "Liste de courses", "Liste de recettes"];
  final SecureStorageService _secureStorageService = SecureStorageService();
  bool _isLoggedIn = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? userIdString;

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      userIdString = prefs.getInt('userId')?.toString();
    } else {
      userIdString = await _secureStorageService.read('userId');
    }

    setState(() {
      _isLoggedIn = userIdString != null;
      _userId = _isLoggedIn ? int.tryParse(userIdString!) : null;
    });
  }

  void _onScreenSelected(String screen) {
    setState(() {
      _selectedScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn || _userId == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Please log in to access the pantry.'),
          ),
        ),
      );
    }

    Widget currentScreen;
    switch (_selectedScreen) {
      case "Liste de courses":
        currentScreen = GroceryScreen(userId: _userId!);
        break;
      case "Liste de recettes":
        currentScreen = RecipeListScreen(userId: _userId!);
        break;
      default:
        currentScreen = PantryContentScreen(userId: _userId!);
        break;
    }

    final backgroundColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: backgroundColor,
              child: ScreenPicker(
                options: _screenOptions,
                selectedOption: _selectedScreen,
                onOptionSelected: _onScreenSelected,
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: currentScreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}