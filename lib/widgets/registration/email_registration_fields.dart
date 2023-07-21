import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class EmailRegistrationFields extends StatelessWidget {
  const EmailRegistrationFields(
      {super.key, required this.enteredEmail, required this.onValidate});

  final String enteredEmail;
  final void Function(String value, String identifier) onValidate;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: enteredEmail,
      decoration: const InputDecoration(
        label: Text('email'),
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (!EmailValidator.validate(value!)) {
          return 'Enter a valid email';
        }

        return null;
      },
      onSaved: (newValue) {
        onValidate(newValue!, "email");
      },
    );
  }
}
