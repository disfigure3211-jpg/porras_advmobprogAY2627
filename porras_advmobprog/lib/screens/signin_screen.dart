import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/custom_text.dart';
import '../services/user_service.dart';

// Enhancement 2: User authentication.
// Uses UserService to authenticate the user and save the response.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _credentialController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _loginType = 'firebase';

  @override
  void dispose() {
    _credentialController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_loginType == 'dummyjson') {
        final username = _credentialController.text.trim();
        final userData = await UserService().loginUser(
          username,
          _passwordController.text,
        );
        await UserService().saveUserData({
          ...userData,
          'loginType': 'dummyjson',
        });
      } else {
        final email = _credentialController.text.trim();
        final password = _passwordController.text;
        final credential = await signIn(email: email, password: password);
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw Exception('Firebase sign-in returned no user');
        }

        final username = firebaseUser.displayName ??
            email.split('@').first;
        await UserService().saveUserData({
          'id': firebaseUser.uid.hashCode,
          'username': username,
          'email': firebaseUser.email ?? email,
          'firstName': '',
          'lastName': '',
          'gender': '',
          'image': firebaseUser.photoURL ?? '',
          'age': '',
          'contactNo': '',
          'accessToken': firebaseUser.uid,
          'refreshToken': '',
          'loginType': 'firebase',
        });
        await UserService().syncFirebaseUserProfile();
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in failed. Check your credentials.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/star.jpg',
                    width: 160.w,
                    height: 160.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Welcome to HellBExchange',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'firebase',
                        label: Text('Firebase'),
                        icon: Icon(Icons.security),
                      ),
                      ButtonSegment<String>(
                        value: 'dummyjson',
                        label: Text('DummyJSON'),
                        icon: Icon(Icons.api),
                      ),
                    ],
                    selected: {_loginType},
                    onSelectionChanged: (selection) {
                      setState(() => _loginType = selection.first);
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _credentialController,
                    keyboardType: _loginType == 'firebase'
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    decoration: InputDecoration(
                      labelText: _loginType == 'firebase' ? 'Email' : 'Username',
                      prefixIcon: Icon(
                        _loginType == 'firebase'
                            ? Icons.email
                            : Icons.person,
                      ),
                    ),
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      if (input.isEmpty) {
                        return _loginType == 'firebase'
                            ? 'Enter your email'
                            : 'Enter your username';
                      }
                      if (_loginType == 'firebase' &&
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                              .hasMatch(input)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        tooltip: 'Show password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your password'
                        : null,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Sign In'),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pushNamed(context, '/signup'),
                      child: const Text('Create an account'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
