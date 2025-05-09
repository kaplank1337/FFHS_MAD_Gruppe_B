import 'package:einkaufslite/screens/authenticate/authenticate_screen.dart';
import 'package:einkaufslite/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = false;

    if (!isLoggedIn) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
