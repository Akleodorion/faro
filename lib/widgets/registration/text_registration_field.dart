import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class TextRegistrationField extends StatelessWidget {
  const TextRegistrationField(
      {super.key,
      required this.enteredValue,
      required this.onValidate,
      required this.fieldType});

  final String enteredValue;
  final String fieldType;
  final void Function(String value, String identifier) onValidate;
  @override
  Widget build(BuildContext context) {
    final RegExp regexp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    Widget content = TextFormField(
      initialValue: enteredValue,
      autocorrect: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        label: Text(fieldType),
      ),
      validator: (value) {
        if (value == null || value.trim() == '') {
          return 'Please enter a non null value';
        }
        return null;
      },
      onSaved: (newValue) {
        onValidate(newValue!, fieldType);
      },
    );

    if (fieldType == 'password') {
      content = TextFormField(
        initialValue: enteredValue,
        obscureText: true,
        autocorrect: false,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          label: Text(fieldType),
        ),
        validator: (value) {
          if (value == null || value.trim() == '' || value.trim().length < 6) {
            return 'Enter a valid password min 6 chars.';
          }
          return null;
        },
        onSaved: (newValue) {
          onValidate(newValue!, fieldType);
        },
      );
    }

    if (fieldType == 'email') {
      content = TextFormField(
        initialValue: enteredValue,
        decoration: InputDecoration(
          label: Text(fieldType),
        ),
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (!EmailValidator.validate(value!) || !regexp.hasMatch(value)) {
            return 'Enter a valid email';
          }

          return null;
        },
        onSaved: (newValue) {
          onValidate(newValue!, fieldType);
        },
      );
    }

    return content;
  }
}
