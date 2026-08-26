import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  ThemeData _blackChromeTheme({required bool isDark}) {
    const chrome = Color(0xFFC0C0C0);
    const lightChrome = Color(0xFFE5E4E2);
    const charcoal = Color(0xFF202020);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: chrome,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final surfaceColor = isDark ? charcoal : lightChrome;
    final textColor = isDark ? Colors.white : Colors.black;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme.copyWith(
        primary: chrome,
        secondary: lightChrome,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? charcoal : chrome,
        foregroundColor: textColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: chrome,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: chrome,
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

  ThemeData get lightTheme => _blackChromeTheme(isDark: false);

  ThemeData get darkTheme => _blackChromeTheme(isDark: true);
}
