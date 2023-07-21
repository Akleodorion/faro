import 'package:flutter/material.dart';
import '../widgets/registration/login_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.onLogStatusChange});

  final void Function() onLogStatusChange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faro²'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.replay_outlined),
          )
        ],
      ),
      body: LoginCard(onLogStatusChange: onLogStatusChange),
    );
  }
}
