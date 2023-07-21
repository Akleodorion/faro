import 'package:flutter/material.dart';

class PasswordRegistrationField extends StatelessWidget {
  const PasswordRegistrationField(
      {super.key,
      required this.enteredPassword,
      required this.onValidate,
      this.label = "password"});

  final String enteredPassword;
  final String label;
  final void Function(String value, String identifier) onValidate;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: enteredPassword,
      obscureText: true,
      autocorrect: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        label: Text(label),
      ),
      validator: (value) {
        if (value == null || value.trim() == '' || value.trim().length < 6) {
          return 'Enter a valid password min 6 chars.';
        }
        return null;
      },
      onSaved: (newValue) {
        onValidate(newValue!, 'password');
      },
    );
  }
}
