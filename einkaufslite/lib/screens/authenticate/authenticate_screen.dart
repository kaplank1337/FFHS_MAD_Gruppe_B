import 'package:einkaufslite/services/auth.dart';
import 'package:einkaufslite/widgets/app_background.dart';
import 'package:einkaufslite/widgets/app_button.dart';
import 'package:einkaufslite/widgets/app_title.dart';
import 'package:einkaufslite/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

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
                    child: _LoginForm(
                      formKey: _loginFormKey,
                      onEmailSaved: (value) => emailAddress = value!,
                      onPasswordSaved: (value) => password = value!,
                      onSubmit: _handleLogin,
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

  void _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      final user = await _auth.signInWithEmailAndPassword(emailAddress, password);
      if (user != null) {
        Navigator.pushNamed(context, '/home');
      }
    }
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final FormFieldSetter<String> onEmailSaved;
  final FormFieldSetter<String> onPasswordSaved;
  final VoidCallback onSubmit;

  const _LoginForm({
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
            "Login",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          AppTextField(
            hint: "E-Mail",
            initialValue: "te@te.ch",
            validator: (value) =>
                value!.isEmpty ? "Enter an email" : null,
            onSaved: onEmailSaved,
          ),
          const SizedBox(height: 16),
          AppTextField(
            hint: "Password",
            obscureText: true,
            initialValue: "test12",
            validator: (value) =>
                value!.length < 6 ? "Password must be at least 6 characters" : null,
            onSaved: onPasswordSaved,
          ),
          const SizedBox(height: 32),
          AppButton(
            label: "Login",
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text(
              "Sign up",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
