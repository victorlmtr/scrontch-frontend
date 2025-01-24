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
    // If user is not logged in, show login message
    if (!_isLoggedIn || _userId == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('Please log in to access the pantry.'),
          ),
        ),
      );
    }

    // User is logged in, show selected screen
    Widget currentScreen;
    if (_selectedScreen == "Liste de courses") {
      currentScreen = GroceryScreen(userId: _userId!);
    } else {
      currentScreen = PantryContentScreen(userId: _userId!);
    }

    // Return the main scaffold with the selected screen
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenPicker(
              options: _screenOptions,
              selectedOption: _selectedScreen,
              onOptionSelected: _onScreenSelected,
            ),
            Expanded(
              child: currentScreen,
            ),
          ],
        ),
      ),
    );
  }
}