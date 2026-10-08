import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart' as app_models;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

ValueNotifier<UserService> userService = ValueNotifier(UserService());

class UserService {
  static const _userDataKey = 'authenticated_user';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final normalized = Map<String, dynamic>.from(userData);
    final loginType = normalized['loginType'] ?? normalized['provider'];
    if (loginType == null || (loginType is String && loginType.isEmpty)) {
      normalized['loginType'] = 'firebase';
    }
    if (normalized['id'] is String && normalized['id'].isNotEmpty) {
      normalized['id'] = normalized['id'].hashCode;
    }
    final user = app_models.User.fromJson(normalized);
    await preferences.setString(_userDataKey, jsonEncode(user.toJson()));
  }

  Future<void> syncFirebaseUserProfile() async {
    final firebaseUser = currentUser;
    if (firebaseUser == null) return;

    final localData = await getUserData();
    final name = (firebaseUser.displayName ?? '').trim();
    final nameParts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final firstName = (localData['firstName'] as String? ?? '').trim();
    final lastName = (localData['lastName'] as String? ?? '').trim();
    final username = (localData['username'] as String? ?? name).trim();
    final profile = <String, dynamic>{
      'id': firebaseUser.uid,
      'username': username,
      'email': firebaseUser.email ?? '',
      'avatar': firebaseUser.photoURL ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (firstName.isNotEmpty || nameParts.isNotEmpty) {
      profile['firstName'] = firstName.isNotEmpty ? firstName : nameParts.first;
    }
    if (lastName.isNotEmpty || nameParts.length > 1) {
      profile['lastName'] = lastName.isNotEmpty
          ? lastName
          : nameParts.skip(1).join(' ');
    }

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(profile, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>> getUserData() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_userDataKey);
    if (encoded == null || encoded.isEmpty) {
      final firebaseUser = currentUser;
      if (firebaseUser == null) return {};
      return {
        'id': firebaseUser.uid.hashCode,
        'username': firebaseUser.displayName ??
            (firebaseUser.email ?? 'user').split('@').first,
        'email': firebaseUser.email ?? '',
        'firstName': '',
        'lastName': '',
        'gender': '',
        'image': firebaseUser.photoURL ?? '',
        'age': '',
        'contactNo': '',
        'accessToken': firebaseUser.uid,
        'refreshToken': '',
        'loginType': 'firebase',
      };
    }

    final decoded = jsonDecode(encoded);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<app_models.User> getUser() async {
    final data = await getUserData();
    if (data.isEmpty) throw Exception('No saved user session');
    final user = app_models.User.fromJson(data);
    if (user.email.isEmpty && currentUser != null) {
      final firebaseUser = currentUser!;
      return app_models.User(
        id: firebaseUser.uid.hashCode,
        username: firebaseUser.displayName ??
            (firebaseUser.email ?? 'user').split('@').first,
        email: firebaseUser.email ?? '',
        firstName: user.firstName,
        lastName: user.lastName,
        gender: user.gender,
        image: firebaseUser.photoURL ?? user.image,
        age: user.age,
        contactNo: user.contactNo,
        accessToken: firebaseUser.uid,
        refreshToken: '',
        loginType: 'firebase',
      );
    }
    return user;
  }

  Future<bool> isLoggedIn() async {
    if (currentUser != null) return true;
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
  final service = UserService();
  final data = await service.getUserData();
  if (data.isNotEmpty) {
    data['username'] = username;
    data['loginType'] = data['loginType'] ?? 'dummyjson';
    await service.saveUserData(data);
  }

  if (currentUser != null) {
    await currentUser?.updateDisplayName(username);
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
