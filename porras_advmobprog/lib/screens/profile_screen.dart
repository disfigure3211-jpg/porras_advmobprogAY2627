import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 3: User model and user-based cart.
// Displays saved user data and provides the authenticated user's ID to app flows.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<User> _loadUser() async {
    final data = await UserService().getUserData();
    if (data.isEmpty) throw Exception('No saved user session');
    return User.fromJson(data);
  }

  Future<void> _logout() async {
    await UserService().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
  }

  Future<void> _editUsername(User user) async {
    if (!mounted) return;
    if (user.loginType != 'firebase') {
      _showMessage('DummyJSON users can only use the local profile data.');
      return;
    }

    final controller = TextEditingController(text: user.username);
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted) return;
    if (username == null || username.isEmpty) return;
    try {
      await updateUsername(username: username);
      if (!mounted) return;
      setState(() => _userFuture = _loadUser());
    } catch (_) {
      if (mounted) {
        _showMessage('Could not update username.');
      }
    }
  }

  Future<void> _changePassword() async {
    final user = await _userFuture;
    if (!mounted) return;
    if (user.loginType != 'firebase') {
      _showMessage('Password change is available only for Firebase accounts.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final emailController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value == null || !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current password'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your current password'
                    : null,
              ),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: (value) => value == null || value.length < 6
                    ? 'Use at least 6 characters'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
    final email = emailController.text.trim();
    final currentPassword = currentController.text;
    final newPassword = newController.text;
    emailController.dispose();
    currentController.dispose();
    newController.dispose();
    if (!mounted) return;
    if (confirmed != true) return;
    try {
      await resetPasswordFromCurrentPassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        email: email,
      );
      if (mounted) {
        _showMessage('Password changed successfully.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not change password. Check your credentials.');
      }
    }
  }

  Future<void> _deleteAccount(User user) async {
    if (!mounted) return;
    if (user.loginType != 'firebase') {
      _showMessage('Account deletion is available only for Firebase accounts.');
      return;
    }

    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password for ${user.email}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    final password = passwordController.text;
    passwordController.dispose();
    if (!mounted) return;
    if (confirmed != true || password.isEmpty) return;
    try {
      await deleteAccount(email: user.email, password: password);
      await UserService().logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
    } catch (_) {
      if (mounted) {
        _showMessage('Could not delete account. Check your password.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted || !context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('No saved profile found.'));
        }

        final user = snapshot.data!;
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48.r,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: user.image.isNotEmpty
                    ? NetworkImage(user.image)
                    : null,
                child: user.image.isEmpty
                    ? Icon(Icons.person, size: 48.sp, color: Colors.black)
                    : null,
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: CustomText(
                text: '@${user.username}',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            _ProfileItem(label: 'Login type', value: user.loginType),
            _ProfileItem(label: 'Email', value: user.email),
            _ProfileItem(label: 'First name', value: user.firstName),
            _ProfileItem(label: 'Last name', value: user.lastName),
            _ProfileItem(label: 'Gender', value: user.gender),
            _ProfileItem(label: 'Age', value: user.age),
            _ProfileItem(label: 'Contact number', value: user.contactNo),
            _ProfileItem(label: 'User ID', value: '${user.id}'),
            SizedBox(height: 24.h),
            OutlinedButton.icon(
              onPressed: () => _editUsername(user),
              icon: const Icon(Icons.edit),
              label: const Text('Update username'),
            ),
            OutlinedButton.icon(
              onPressed: _changePassword,
              icon: const Icon(Icons.lock_reset),
              label: const Text('Change password'),
            ),
            OutlinedButton.icon(
              onPressed: () => _deleteAccount(user),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete account'),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value.isEmpty ? 'Not provided' : value),
    );
  }
}
