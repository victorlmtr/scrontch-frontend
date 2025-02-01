import 'package:flutter/material.dart';

class RecipeListScreen extends StatefulWidget {
  final int userId;

  const RecipeListScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Recipe List Screen - Coming Soon'),
    );
  }
}