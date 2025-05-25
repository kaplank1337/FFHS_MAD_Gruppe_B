import 'package:einkaufslite/services/auth.dart';
import 'package:einkaufslite/widgets/app_background.dart';
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
              child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Einkauf App",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      initialValue: "te@te.ch",
                      decoration: InputDecoration(
                        labelText: "E-Mail",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter an email" : null,
                      onSaved: (value) => emailAddress = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: "test12",
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) => value!.length < 6
                          ? "Password must be at least 6 characters"
                          : null,
                      onSaved: (value) => password = value!,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _handleLogin,
                      child: const Text("Login"),
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      final user =
          await _auth.signInWithEmailAndPassword(emailAddress, password);
      if (user != null) {
        Navigator.pushNamed(context, '/home');
      }
    }
  }
}
