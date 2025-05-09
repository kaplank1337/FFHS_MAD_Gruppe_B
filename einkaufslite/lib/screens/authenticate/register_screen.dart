import 'package:einkaufslite/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Register> {
  final AuthService _auth = AuthService();
  GlobalKey<FormState> _loginFormKey = GlobalKey();

  String emailAddress = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Einkauf App")),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [_buildTitle(), _buildLoginForm()],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Sign up",
      style: TextStyle(fontSize: 35, fontWeight: FontWeight.w300),
    );
  }

  Widget _buildLoginForm() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.90,
      height: MediaQuery.sizeOf(context).height * 0.30,
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              initialValue: "te@te.ch",
              validator: (value) => value!.isEmpty ? "Enter an email" : null,
              onSaved: (value) {
                setState(() {
                  emailAddress = value!;
                });
              },
              decoration: InputDecoration(hintText: "E-Mail"),
            ),
            TextFormField(
              initialValue: "test12",
              validator:
                  (value) =>
                      value!.isEmpty ? "Enter a password 6+ chars long" : null,
              onSaved: (value) {
                setState(() {
                  password = value!;
                });
              },
              obscureText: true,

              decoration: InputDecoration(hintText: "Password"),
            ),
            _registerButton(),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.60,
      child: ElevatedButton(
        onPressed: () async {
          if (_loginFormKey.currentState!.validate()) {
            _loginFormKey.currentState!.save();
            await _auth.registerWithEmailAndPassword(emailAddress, password);
          }
        },
        child: const Text("Save"),
      ),
    );
  }
}
