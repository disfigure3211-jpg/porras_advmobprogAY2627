import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart' as app_models;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

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
    final user = app_models.User.fromJson(userData);
    await preferences.setString(_userDataKey, jsonEncode(user.toJson()));
  }

  Future<Map<String, dynamic>> getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_userDataKey);
    if (encoded == null || encoded.isEmpty) return {};

    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<app_models.User> getUser() async {
    final data = await getUserData();
    if (data.isEmpty) throw Exception('No saved user session');
    return app_models.User.fromJson(data);
  }

  // Enhancement 1: Persistent authentication.
  // Checks saved login data before opening the main application.
  Future<bool> isLoggedIn() async {
    final data = await getUserData();
    final token = data['accessToken'] ?? data['token'];
    return data['id'] != null && token is String && token.isNotEmpty;
  }

  Future<void> logout() async {
    await signOut();
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userDataKey);
  }
}

final firebase_auth.FirebaseAuth firebaseAuth =
  firebase_auth.FirebaseAuth.instance;

firebase_auth.User? get currentUser => firebaseAuth.currentUser;

Stream<firebase_auth.User?> get authStateChanges =>
  firebaseAuth.authStateChanges();

Future<firebase_auth.UserCredential> signIn({
  required String email,
  required String password,
}) async {
  return await firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<firebase_auth.UserCredential> createAccount({
  required String email,
  required String password,
}) async {
  return await firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}

Future<void> signOut() async {
  await firebaseAuth.signOut();
}

Future<void> updateUsername({required String username}) async {
  await currentUser?.updateDisplayName(username);
  final service = UserService();
  final data = await service.getUserData();
  if (data.isNotEmpty) {
    data['username'] = username;
    await service.saveUserData(data);
  }
}

Future<void> deleteAccount({
  required String email,
  required String password,
}) async {
  final credential = firebase_auth.EmailAuthProvider.credential(
    email: email,
    password: password,
  );

  await currentUser!.reauthenticateWithCredential(credential);
  await currentUser!.delete();
  await firebaseAuth.signOut();
}

Future<void> resetPasswordFromCurrentPassword({
  required String currentPassword,
  required String newPassword,
  required String email,
}) async {
  final credential = firebase_auth.EmailAuthProvider.credential(
    email: email,
    password: currentPassword,
  );

  await currentUser!.reauthenticateWithCredential(credential);
  await currentUser!.updatePassword(newPassword);
}
