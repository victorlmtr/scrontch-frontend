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
    String? refreshToken;
    String? username;
    int? userId;
    String? role;

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      refreshToken = prefs.getString('refreshToken');
      username = prefs.getString('username');
      userId = prefs.getInt('userId');
      role = prefs.getString('role');
      _isLoginDialogShown = prefs.getBool('isLoginDialogShown') ?? false;
    } else {
      token = await _secureStorageService.read('token');
      refreshToken = await _secureStorageService.read('refreshToken');
      username = await _secureStorageService.read('username');
      userId = int.tryParse(await _secureStorageService.read('userId') ?? '');
      role = await _secureStorageService.read('role');
    }

    // Refresh token if necessary
    if (token == null || token.isEmpty) {
      token = await _refreshToken(refreshToken);
    }

    setState(() {
      _isLoggedIn = token != null;
      _username = username ?? '';
    });

    if (!_isLoggedIn && !_isLoginDialogShown) {
      Future.delayed(Duration.zero, () {
        _showLoginDialog(context);
      });
    }
  }

  // Save login info
  Future<void> _saveLoginInfo(String token, String username, int userId, String role) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', username);
      await prefs.setInt('userId', userId);
      await prefs.setString('role', role);
    } else {
      await _secureStorageService.save('token', token);
      await _secureStorageService.save('username', username);
      await _secureStorageService.save('userId', userId.toString());
      await _secureStorageService.save('role', role);
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
                Navigator.of(context).pop ();
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

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                await _logout();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    const String apiUrl = 'http://victorl.xyz:8086/api/v1/auth/logout';

    try {
      String? token = await _secureStorageService.read('token');
      if (token == null || token.isEmpty) {
        print('No token found. Cannot logout.');
        return;
      }

      print('Token: $token'); // Debugging: Log the token

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Headers: ${{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }}'); // Debugging: Log the headers

      if (response.statusCode == 200) {
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
        } else {
          await _secureStorageService.delete('token');
          await _secureStorageService.delete('username');
          await _secureStorageService.delete('userId');
          await _secureStorageService.delete('role');
        }

        setState(() {
          _isLoggedIn = false;
          _username = '';
        });
      } else {
        print('Failed to logout. Status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Debugging: Log response body
      }
    } catch (e) {
      print('Error occurred while logging out: $e');
    }
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

        // Save token, refresh token, username, and user ID
        await _saveLoginInfo(data['token'], data['username'], data['userid'], data['role']);
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('refreshToken', data['refreshToken']);
        } else {
          await _secureStorageService.save('refreshToken', data['refreshToken']);
        }

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


  Future<String?> _refreshToken(String? refreshToken) async {
    const String apiUrl = 'http://victorl.xyz:8086/api/v1/auth/refresh-token';

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String newToken = data['accessToken'];
        String newRefreshToken = data['refreshToken'];

        // Save new tokens
        if (kIsWeb) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);
          await prefs.setString('refreshToken', newRefreshToken);
        } else {
          await _secureStorageService.save('token', newToken);
          await _secureStorageService.save('refreshToken', newRefreshToken);
        }

        return newToken;
      } else {
        print('Failed to refresh token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error occurred while refreshing token: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              if (_isLoggedIn) {
                _showLogoutDialog(context); // Show logout dialog if logged in
              } else {
                _showLoginDialog(context); // Show login dialog if logged out
              }
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