import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;

  const AppTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.initialValue,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
