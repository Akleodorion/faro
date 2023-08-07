import 'package:flutter/material.dart';
import './login_screen.dart';
import './home.dart';

class FaroScreen extends StatefulWidget {
  const FaroScreen({super.key});

  @override
  State<FaroScreen> createState() {
    return _FaroScreenState();
  }
}

class _FaroScreenState extends State<FaroScreen> {
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
      content = HomeScreen(
        onLogStatusChange: _setLoggedStatus,
      );
    }
    return content;
  }
}
