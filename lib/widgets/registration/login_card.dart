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
  bool? _isChecked;
  bool _isLogin = true;
  bool _isLoading = false;
  String? _enteredName;
  String? token;
  String? _enteredEmail;
  String? _enteredPassword;

  @override
  void initState() {
    super.initState();
    _initFormValues();
  }

  Future<void> _initFormValues() async {
    final db = await getDatabase();
    final userLoginData = await db.query('user_login');
    setState(() {
      _enteredEmail = userLoginData[0]["email"] as String;
      _enteredPassword = userLoginData[0]["password"] as String;
      token = userLoginData[0]["token"] as String;
      _isChecked = userLoginData[0]["checked"] == 'true';
    });
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

    ref.read(loggedStatusProvider.notifier).appendUserLoginData(
        _enteredEmail!, _enteredPassword!, token ?? '', _isChecked.toString());
  }

  @override
  Widget build(BuildContext context) {
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
                        Checkbox(
                          value: _isChecked ?? false,
                          onChanged: (value) {
                            // print(value);

                            setState(() {
                              _isChecked = value;
                            });
                          },
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        const Text('Remember me ?'),
                      ],
                    ),
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
