import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    bool isLoggedIn = false; // Replace with actual login check

    // Show login dialog if not logged in
    if (!isLoggedIn) {
      Future.delayed(Duration.zero, () {
        _showLoginDialog(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }

  void _showLoginDialog(BuildContext context) {
    String username = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connexion'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Pseudo'),
                  onChanged: (value) {
                    username = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Se connecter'),
              onPressed: () {
                // Handle login logic here
                print('Username: $username, Password: $password');
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Mot de passe oublié ?'),
              onPressed: () {
                // Handle forgot password logic here
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Créer un compte'),
              onPressed: () {
                // Handle create account logic here
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}