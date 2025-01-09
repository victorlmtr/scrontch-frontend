import 'package:flutter/material.dart';
import 'package:scrontch_flutter/screens/home_screen.dart';
import 'package:scrontch_flutter/screens/pantry_screen.dart';
import 'package:scrontch_flutter/screens/profile_screen.dart';
import 'package:scrontch_flutter/screens/recipes_screen.dart';
import 'package:scrontch_flutter/screens/temporary_test_screen.dart';
import 'widgets/custom_bottom_navigation_bar.dart';
import 'util.dart';
import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Roboto Flex", "Bebas Neue");

    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: 'Scrontch',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: TemporaryTestScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Define the list of screens
  final List<Widget> _screens = [
    HomeScreen(),
    RecipesScreen(),
    PantryScreen(),
    ProfileScreen(),
  ];

  // Define the navigation logic
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}