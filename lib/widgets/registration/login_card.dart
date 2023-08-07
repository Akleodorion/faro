import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utilities/database.dart';
import '../registration/text_registration_field.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key, required this.onLogStatusChange});

  final void Function() onLogStatusChange;

  @override
  State<LoginCard> createState() {
    return _LoginCardState();
  }
}

class _LoginCardState extends State<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  bool? _isChecked;
  bool _isLogin = true;
  bool _isLoading = false;
  String? _enteredName;
  String? token;
  String? _enteredEmail;
  String? _enteredPassword;
  bool _initInfoLoaded = false;

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

  _loginRequest(String enteredEmail, String enteredPassword) async {
    // on affiche un loading spiner et désactive les boutons le temps de la requête.
    setState(() {
      _isLoading = true;
    });

    // je fais la requête de connexion
    final url = Uri.http('localhost:3001', 'login');
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

    final bodyData = json.decode(response.body);
    _snackBarMessage(bodyData);

    if (response.statusCode >= 400) {
      return null;
    }

    response.headers.removeWhere((key, value) => key != "authorization");
    final token = response.headers["authorization"];

    appendUserLoginData(
        _enteredEmail!, _enteredPassword!, token!, _isChecked.toString());

    widget.onLogStatusChange();
  }

  @override
  void initState() {
    super.initState();
    _initFormValues();
  }

  Future<void> _initFormValues() async {
    final db = await getDatabase();
    final userLoginData = await db.query('user_login');

    // 1er cas, première connexion et pas de token.
    if (userLoginData.isEmpty) {
      setState(() {
        _initInfoLoaded = true;
        _isChecked = false;
        _enteredEmail = "";
        _enteredPassword = "";
        token = "";
      });
      return;
    }

    setState(() {
      _isChecked = userLoginData[0]["checked"] == 'true';
    });

    if (_isChecked == false) {
      // on fait la demande de connexion via le token.
      final url = Uri.http('localhost:3001', 'login');
      final response = await http.post(
        url,
        headers: {'Authorization': userLoginData[0]["token"] as String},
      );

      // token valide.
      if (response.statusCode == 200) {
        widget.onLogStatusChange();
        return;
      }

      // Si le token est invalide.
      setState(() {
        _enteredEmail = "";
        _enteredPassword = "";
        token = "";
        _initInfoLoaded = true;
      });

      return;
    } else {
      // on fait la demande de connexion via le token.
      final url = Uri.http('localhost:3001', 'login');
      final response = await http.post(
        url,
        headers: {'Authorization': userLoginData[0]["token"] as String},
      );

      // token valide.
      if (response.statusCode == 200) {
        widget.onLogStatusChange();
        return;
      }

      // Si le token est invalide.
      setState(() {
        _enteredEmail = userLoginData[0]["email"] as String;
        _enteredPassword = userLoginData[0]["password"] as String;
        token = "";
        _initInfoLoaded = true;
      });
    }
    //
  }

  void _createUserAccount() async {
    // Récupérer les données utilisateurs

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
    final url = Uri.http('localhost:3001', 'signup');
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
    final data = json.decode(response.body);
    _snackBarMessage(data);
    if (response.statusCode >= 400) {
      return;
    }

    _loginRequest(_enteredEmail!, _enteredPassword!);
  }

  void _userLogin() async {
    // Je récupère les entrées utilisateurs
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }

    _loginRequest(_enteredEmail!, _enteredPassword!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const CircularProgressIndicator();

    if (_initInfoLoaded == true) {
      content = Padding(
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
      );
    }

    return Center(child: content);
  }
}
