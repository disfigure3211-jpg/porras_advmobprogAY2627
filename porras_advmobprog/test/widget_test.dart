import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:porras_advmobprog/main.dart';

void main() {
  testWidgets('app builds the splash screen on startup', (tester) async {
    await tester.pumpWidget(const PorrasAdvMobProg());
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('HellBExchange'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
