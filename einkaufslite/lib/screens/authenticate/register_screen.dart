import 'package:einkaufslite/services/auth.dart';
import 'package:einkaufslite/widgets/app_background.dart';
import 'package:einkaufslite/widgets/app_button.dart';
import 'package:einkaufslite/widgets/app_text_field.dart';
import 'package:einkaufslite/widgets/app_title.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  String emailAddress = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppTitle(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
                    child: _RegisterForm(
                      formKey: _registerFormKey,
                      onEmailSaved: (value) => emailAddress = value!,
                      onPasswordSaved: (value) => password = value!,
                      onSubmit: _handleRegister,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_registerFormKey.currentState!.validate()) {
      _registerFormKey.currentState!.save();
      await _auth.registerWithEmailAndPassword(emailAddress, password);
      Navigator.pushNamed(context, '/home');
    }
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onEmailSaved;
  final FormFieldSetter<String> onPasswordSaved;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.onEmailSaved,
    required this.onPasswordSaved,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Sign up",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            hint: "E-Mail",
            validator: (value) =>
                value!.isEmpty ? "Bitte gib eine E-Mail an" : null,
            onSaved: onEmailSaved,
          ),
          const SizedBox(height: 16),
          AppTextField(
            hint: "Passwort",
            obscureText: true,
            validator: (value) => value!.length < 6
                ? "Passwort muss mindestens 6 Zeichen haben"
                : null,
            onSaved: onPasswordSaved,
          ),
          const SizedBox(height: 32),
          AppButton(
            label: "Speichern",
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Zurück zum Login",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
