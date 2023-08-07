import 'package:flutter/material.dart';
import '../utilities/database.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLogStatusChange});

  final void Function() onLogStatusChange;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // faire une fonction qui delete la session en cours.
  void _userLogout() async {
    final db = await getDatabase();
    final userLoginData = await db.query('user_login');
    final token = userLoginData[0]["token"];

    final uri = Uri.http('localhost:3001', 'logout');
    http.delete(
      uri,
      headers: {
        'Authorization': token.toString(),
      },
    );
    widget.onLogStatusChange();
  }

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
        child: Center(
          child: IconButton(
            onPressed: _userLogout,
            icon: const Icon(Icons.exit_to_app, size: 42),
          ),
        ),
      ),
    );
  }
}
