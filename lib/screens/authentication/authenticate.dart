import 'package:flutter/material.dart';
import 'package:home_stock/screens/authentication/sign_in.dart';
import 'package:home_stock/screens/authentication/register.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/auth_strings.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showSignIn) {
      return SignIn(toggleView: toggleView);
    }
    else{
      return Register(toggleView: toggleView);
    }
  }
}