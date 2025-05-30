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
              const AppTitle(), // Gleicher Titel wie bei Login
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
                    child: Form(
                      key: _registerFormKey,
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
                            onSaved: (value) => emailAddress = value!,
                          ),
                          const SizedBox(height: 16),

                          /// Passwort Feld (wie Login)
                          AppTextField(
                            hint: "Passwort",
                            obscureText: true,
                            validator: (value) => value!.length < 6
                                ? "Passwort muss mindestens 6 Zeichen haben"
                                : null,
                            onSaved: (value) => password = value!,
                          ),
                          const SizedBox(height: 32),

                          /// Speichern-Button (wie Login)
                          AppButton(
                            label: "Speichern",
                            onPressed: _handleRegister,
                          ),
                          const SizedBox(height: 12),

                          /// Link zurück zum Login
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
