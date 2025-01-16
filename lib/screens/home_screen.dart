import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:scrontch_flutter/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/secure_storage_service.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _secureStorageService = SecureStorageService();
  bool _isLoggedIn = false;
  String _username = '';
  bool _isLoginDialogShown = false; // Flag to track dialog state

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if the user is logged in
  Future<void> _checkLoginStatus() async {
    String? token;
    String? username;

    if (kIsWeb) {
      // Use shared_preferences for web
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      username = prefs.getString('username');
      _isLoginDialogShown = prefs.getBool('isLoginDialogShown') ?? false; // Check if the dialog has been shown
    } else {
      // Use SecureStorageService for mobile
      token = await _secureStorageService.read('token');
      username = await _secureStorageService.read('username');
    }

    setState(() {
      _isLoggedIn = token != null;
      _username = username ?? '';
    });

    // Show login dialog if not logged in and dialog hasn't been shown before
    if (!_isLoggedIn && !_isLoginDialogShown) {
      Future.delayed(Duration.zero, () {
        _showLoginDialog(context);
      });
    }
  }

  // Save login info
  Future<void> _saveLoginInfo(String token, String username) async {
    if (kIsWeb) {
      // Use shared_preferences for web
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
    } else {
      // Use SecureStorageService for mobile
      await _secureStorageService.save('token', token);
      await _secureStorageService.save('username', username);
    }
  }

  // Save flag that login dialog has been shown
  Future<void> _markLoginDialogAsShown() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoginDialogShown', true); // Set flag to true after dialog is shown
    }
  }

  // Show login dialog if not logged in
  void _showLoginDialog(BuildContext context) {
    String username = '';
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Username or Email'),
                  onChanged: (value) {
                    username = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Password'),
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
              child: Text('Login'),
              onPressed: () async {
                bool success = await _login(context, username, password);

                if (success) {
                  Navigator.of(context).pop(); // Close the dialog on success
                  _markLoginDialogAsShown(); // Mark dialog as shown
                } else {
                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed. Please try again.')),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Forgot Password?'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        TextButton(
        child: Text('Create Account'),
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
  }

  // Login API Call
  Future<bool> _login(BuildContext context, String username, String password) async {
    const String apiUrl = 'http://victorl.xyz:8086/api/v1/auth/login';

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

        // Save token and user info
        await _saveLoginInfo(data['token'], data['username']);

        // Update login state
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: Center(
        child: Text(
          _isLoggedIn ? 'Welcome $_username!' : 'Welcome!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
