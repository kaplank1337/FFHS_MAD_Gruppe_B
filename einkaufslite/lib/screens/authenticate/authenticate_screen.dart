import 'package:einkaufslite/services/auth.dart';
import 'package:einkaufslite/widgets/app_background.dart';
import 'package:einkaufslite/widgets/app_button.dart';
import 'package:einkaufslite/widgets/app_title.dart';
import 'package:einkaufslite/widgets/app_text_field.dart'; // <--- Wichtig
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
                    child: Form(
                      key: _loginFormKey,
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

                          /// E-Mail Feld
                          AppTextField(
                            hint: "E-Mail",
                            initialValue: "te@te.ch",
                            validator: (value) =>
                                value!.isEmpty ? "Enter an email" : null,
                            onSaved: (value) => emailAddress = value!,
                          ),
                          const SizedBox(height: 16),

                          /// Passwort-Feld
                          AppTextField(
                            hint: "Password",
                            obscureText: true,
                            initialValue: "test12",
                            validator: (value) => value!.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                            onSaved: (value) => password = value!,
                          ),
                          const SizedBox(height: 32),

                          /// Login Button
                          AppButton(
                            label: "Login",
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 12),

                          /// Sign up
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
