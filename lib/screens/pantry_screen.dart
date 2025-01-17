import 'package:flutter/material.dart';
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
  final List<String> _screenOptions = ["Garde-manger", "Liste de courses"];
  final SecureStorageService _secureStorageService = SecureStorageService();
  bool _isLoggedIn = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Check if the user is logged in and retrieve userId
    String? userIdString = await _secureStorageService.read('userId');
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
    Widget currentScreen;
    if (_selectedScreen == "Liste de courses") {
      currentScreen = GroceryScreen();
    } else {
      if (_isLoggedIn && _userId != null) {
        currentScreen = PantryContentScreen(userId: _userId!);
      } else {
        // Show a message or redirect to login if not logged in
        return Scaffold(
          body: Center(
            child: Text('Please log in to access the pantry.'),
          ),
        );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          ScreenPicker(
            options: _screenOptions,
            selectedOption: _selectedScreen,
            onOptionSelected: _onScreenSelected,
          ),
          // The current screen content (either GroceryScreen or PantryContentScreen)
          Expanded(
            child: currentScreen,
          ),
        ],
      ),
    );
  }
}