import 'package:flutter/material.dart';
import '../widgets/screen_picker.dart';
import 'grocery_screen.dart'; // Import your GroceryScreen
import 'pantry_content_screen.dart'; // Import your PantryContentScreen

class PantryScreen extends StatefulWidget {
  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _selectedScreen = "Garde-manger"; // Default selected screen

  final List<String> _screenOptions = ["Garde-manger", "Liste de courses"];

  void _onScreenSelected(String screen) {
    setState(() {
      _selectedScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    if (_selectedScreen == "Liste de courses") {
      currentScreen = GroceryScreen(); // Display GroceryScreen
    } else {
      currentScreen = PantryContentScreen(); // Display PantryContentScreen
    }

    return Scaffold(
      body: Column(
        children: [
          // Directly use the ScreenPicker without any additional padding or gap above
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
