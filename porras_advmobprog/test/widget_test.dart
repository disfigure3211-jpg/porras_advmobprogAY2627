import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
void main() {
  runApp(
    ChangeNotifierProvider(
      // Creates an instance of ThemeModel.
      create: (context) => ThemeModel(),
 
      // Sets MyApp as the main application widget.
      child: const MyApp(),
    ),
  );
}
 
 
// It applies the selected light or dark theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  /// to the theme data from the Provider.
  @override
  Widget build(BuildContext context) {
    // Gets the current theme data from ThemeModel.
    final themeModel = Provider.of<ThemeModel>(context);
 
    return MaterialApp(
      // Changes the app theme depending on whether dark mode is enabled or disabled.
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
 
      // Displays MyHome as the home screen.
      home: const MyHome(),
    );
  }
}
 
// ThemeModel manages the current theme state.
 
class ThemeModel with ChangeNotifier {
  // Stores the current theme.
  bool _isDark = false;
 
  /// Returns the current theme state.
  bool get isDark => _isDark;
 
  /// Changes the theme from light mode to dark mode
  void toggleTheme() {
    // Reverses the current theme value.
    _isDark = !_isDark;
 
    // display the updated theme.
    notifyListeners();
  }
}
 
/// It contains a switch for changing the app theme.
class MyHome extends StatelessWidget {
  const MyHome({super.key});
 
  /// Builds the user interface of the home screen.
  @override
  Widget build(BuildContext context) {
    // Gets the current theme data from ThemeModel.
    final themeModel = Provider.of<ThemeModel>(context);
 
    return Scaffold(
      // Displays the application bar.
      appBar: AppBar(
        title: const Text('App State Example'),
 
        // Adds the theme switch to the app bar.
        actions: [
          Switch(
            // Displays the current theme state.
            value: themeModel.isDark,
 
            // Changes the theme when the switch is pressed.
            onChanged: (_) => themeModel.toggleTheme(),
          ),
        ],
      ),
 
      // Displays instructions at the center of the screen.
      body: const Center(
        child: Text(
          'Toggle the theme using the switch in the app bar',
        ),
      ),
    );
  }
}
 