import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './screens/login_screen.dart';
import './screens/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  void _setLoggedStatus() {
    setState(() {
      isLoggedIn = !isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = LoginScreen(
      onLogStatusChange: _setLoggedStatus,
    );
    if (isLoggedIn) {
      content = const HomeScreen();
    }
    return MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        title: 'Faro²',
        home: content);
  }
}
