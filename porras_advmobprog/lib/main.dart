import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Application entry point.
/// can be managed by Provider.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

/// Manages the app-wide theme state using Provider.
/// The theme is shared across multiple screens and not stored locally in
class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Toggles the current theme and notifies listening widgets.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// Root widget that configures themes and routes for the app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ephemeral & App State Lab',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeModel.themeMode,
      home: const CounterScreen(),
      routes: {
        ThemeScreen.routeName: (_) => const ThemeScreen(),
      },
    );
  }
}

/// Counter screen demonstrating ephemeral state with setState.
/// The counter value is stored locally inside this widget state.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int counter = 0;

  /// Increments the locally stored counter value and rebuilds this widget.
  void _incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Open Theme Screen',
            onPressed: () {
              Navigator.pushNamed(context, ThemeScreen.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'This counter uses setState for ephemeral state.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// The switch here updates a global theme state that affects the entire app.
class ThemeScreen extends StatelessWidget {
  static const routeName = '/theme';

  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'Toggle the whole app theme using Provider.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeModel.isDark,
              onChanged: (_) => themeModel.toggleTheme(),
            ),
            const SizedBox(height: 16),
            Text(
              themeModel.isDark ? 'Dark mode is active' : 'Light mode is active',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back to Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
