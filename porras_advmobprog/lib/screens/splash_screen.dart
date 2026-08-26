import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/user_service.dart';

// Enhancement 1: Persistent authentication.
// Checks saved login data before opening the main application.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    var loggedIn = false;
    try {
      final userService = UserService();
      loggedIn = await userService.isLoggedIn().timeout(
        const Duration(seconds: 5),
      );
      if (loggedIn) {
        await userService.getUser().timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      loggedIn = false;
    }
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, loggedIn ? '/home' : '/signin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/hellstar.jpg',
              width: 100.w,
              height: 100.w,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.h),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFE5E4E2),
                  Color(0xFF8A8A8A),
                  Color(0xFFF5F5F5),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ).createShader(bounds),
              child: Text(
                'HellBExchange',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Color(0x99FFFFFF),
                      blurRadius: 8,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
