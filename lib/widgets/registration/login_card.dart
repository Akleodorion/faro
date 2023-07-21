import 'dart:math';

import 'package:faro/providers/logged_status.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../registration/text_registration_field.dart';

class LoginCard extends ConsumerStatefulWidget {
  const LoginCard({super.key, required this.onLogStatusChange});

  final void Function() onLogStatusChange;

  @override
  ConsumerState<LoginCard> createState() {
    return _LoginCardState();
  }
}

class _LoginCardState extends ConsumerState<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _enteredName;
  String? token;
  String? _enteredEmail;
  String? _enteredPassword;

  @override
  void initState() {
    super.initState();
    ref.read(loggedStatusProvider.notifier).loadUserLoginData();
  }

  void _snackBarMessage(data) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(data['status']["message"]),
      ),
    );
  }

  void _setEnteredValue(String value, String identifier) {
    if (identifier == 'email') {
      _enteredEmail = value;
    }
    if (identifier == 'password') {
      _enteredPassword = value;
    }
    if (identifier == 'name') {
      _enteredName = value;
    }
  }

  Future<String?> _loginRequestion(
      String enteredEmail, String enteredPassword) async {
    setState(() {
      // on affiche un loading spiner et désactive les boutons le temps de la requête.
      _isLoading = true;
    });

    // je fais la requête de connexion
    final url = Uri.parse('http://localhost:3001/login');
    final response = await http.post(
      url,
      headers: {'content-type': 'application/json'},
      body: json.encode({
        "user": {
          "email": enteredEmail,
          "password": enteredPassword,
        }
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (!context.mounted) {
      return null;
    }
    final bodyData = json.decode(response.body);
    // affichage du status de la requête
    if (response.statusCode >= 400) {
      _snackBarMessage(bodyData);
      return null;
    } else {
      _snackBarMessage(bodyData);
      // widget.onLogStatusChange();
      // récupère le token.
      // print(response.headers);
    }
    response.headers.removeWhere((key, value) => key != "authorization");
    return response.headers["authorization"];
  }

  void _createUserAccount() async {
    // Récupérer les données users

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }

    // afficher l'attente coté user
    setState(() {
      _isLoading = true;
    });

    // faire la requête POST et attendre la réponse
    final url = Uri.parse('http://localhost:3001/signup');
    final response = await http.post(
      url,
      headers: {'content-type': 'application/json'},
      body: json.encode(
        {
          'user': {
            'email': _enteredEmail,
            'password': _enteredPassword,
            'name': _enteredName,
          }
        },
      ),
    );

    setState(() {
      _isLoading = false;
    });
    // Si positive rediriger vers la page home
    final data = json.decode(response.body);

    if (!context.mounted) {
      return;
    }

    if (response.statusCode >= 400) {
      _snackBarMessage(data);
      return;
    } else {
      _snackBarMessage(data);
    }

    _loginRequestion(_enteredEmail!, _enteredPassword!);
  }

  void _userLogin() async {
    // Je récupère les entrées utilisateurs
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }

    final String? token =
        await _loginRequestion(_enteredEmail!, _enteredPassword!);

    ref
        .read(loggedStatusProvider.notifier)
        .appendUserLoginData(_enteredEmail!, _enteredPassword!, token ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final loggedStatus = ref.watch(loggedStatusProvider);
    if (loggedStatus.isNotEmpty) {
      _enteredEmail = loggedStatus["email"];
      _enteredPassword = loggedStatus["password"];
      token = loggedStatus["token"];
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextRegistrationField(
                        key: ValueKey(Random()),
                        enteredValue: _enteredEmail ?? '',
                        onValidate: _setEnteredValue,
                        fieldType: 'email'),
                    const SizedBox(height: 20),
                    TextRegistrationField(
                        key: ValueKey(Random()),
                        enteredValue: _enteredPassword ?? '',
                        onValidate: _setEnteredValue,
                        fieldType: 'password'),
                    const SizedBox(height: 20),
                    if (!_isLogin)
                      TextRegistrationField(
                          enteredValue: _enteredName ?? '',
                          onValidate: _setEnteredValue,
                          fieldType: 'name'),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed:
                                    _isLogin ? _userLogin : _createUserAccount,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue),
                                child:
                                    Text(_isLogin ? 'Login' : 'Create account'),
                              ),
                        const SizedBox(
                          width: 20,
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    print(loggedStatus);
                                  });
                                },
                          child: Text(_isLogin ? 'Sign up' : 'Sign in'),
                        )
                      ],
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
