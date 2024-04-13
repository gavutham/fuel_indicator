
import "package:flutter/material.dart";
import "package:petrol_indicator/screens/auth/signIn.dart";
import "package:petrol_indicator/screens/auth/signUp.dart";

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool login = true;

  void toggleView () {
    setState(() {
      login = !login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return login ? SignIn(toggleView: toggleView) : SignUp(toggleView: toggleView,);
  }
}
