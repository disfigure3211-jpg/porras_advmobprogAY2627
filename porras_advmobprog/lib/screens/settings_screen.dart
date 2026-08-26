import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

// Enhancement 3: Settings page with Dark/Light theme switch moved here
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Appearance', fontSize: 18.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(text: 'Dark Mode', fontSize: 16.sp),
                Switch(
                  value: themeProvider.isDark,
                  onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
