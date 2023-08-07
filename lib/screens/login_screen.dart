import 'package:flutter/material.dart';
import '../widgets/registration/login_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.onLogStatusChange});

  final void Function() onLogStatusChange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(42, 43, 42, 1),
              Color.fromRGBO(42, 43, 42, 0.2)
            ],
          ),
        ),
        child: LoginCard(onLogStatusChange: onLogStatusChange),
      ),
    );
  }
}
