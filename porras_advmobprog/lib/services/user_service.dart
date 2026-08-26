import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';

// Enhancement 2: User authentication.
// Uses UserService to authenticate the user and save the response.
class UserService {
  static const _userDataKey = 'authenticated_user';

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$host/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid username or password');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid login response');
    }
    return decoded;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final preferences = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);
    await preferences.setString(_userDataKey, jsonEncode(user.toJson()));
  }

  Future<Map<String, dynamic>> getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_userDataKey);
    if (encoded == null || encoded.isEmpty) return {};

    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<User> getUser() async {
    final data = await getUserData();
    if (data.isEmpty) throw Exception('No saved user session');
    return User.fromJson(data);
  }

  // Enhancement 1: Persistent authentication.
  // Checks saved login data before opening the main application.
  Future<bool> isLoggedIn() async {
    final data = await getUserData();
    final token = data['accessToken'] ?? data['token'];
    return data['id'] != null && token is String && token.isNotEmpty;
  }

  Future<void> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userDataKey);
  }
}
