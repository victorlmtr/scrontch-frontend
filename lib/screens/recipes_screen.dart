import 'package:flutter/material.dart';

class RecipesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recettes')),
      body: Center(child: Text('Welcome to the Recipes screen!')),
    );
  }
}