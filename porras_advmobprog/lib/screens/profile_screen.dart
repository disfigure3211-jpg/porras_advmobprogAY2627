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
    _userFuture = UserService().getUser();
  }

  Future<void> _logout() async {
    await UserService().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (_) => false);
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
            _ProfileItem(label: 'Email', value: user.email),
            _ProfileItem(label: 'First name', value: user.firstName),
            _ProfileItem(label: 'Last name', value: user.lastName),
            _ProfileItem(label: 'Gender', value: user.gender),
            _ProfileItem(label: 'User ID', value: '${user.id}'),
            SizedBox(height: 24.h),
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
