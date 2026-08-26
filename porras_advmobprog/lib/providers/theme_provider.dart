import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  ThemeData _blackPinkTheme({required bool isDark}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.pink,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme.copyWith(
        primary: Colors.pinkAccent,
        secondary: Colors.pink,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
      ),
      fontFamily: 'Poppins',
    );
  }

  ThemeData get lightTheme => _blackPinkTheme(isDark: false);

  ThemeData get darkTheme => _blackPinkTheme(isDark: true);
}
