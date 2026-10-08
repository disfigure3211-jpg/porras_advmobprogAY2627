import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:porras_advmobprog/screens/signin_screen.dart';

void main() {
  testWidgets('sign in screen supports both Firebase and DummyJSON modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        builder: (context, _) => const MaterialApp(home: SignInScreen()),
      ),
    );

    expect(find.text('Firebase'), findsOneWidget);
    expect(find.text('DummyJSON'), findsOneWidget);
  });
}
