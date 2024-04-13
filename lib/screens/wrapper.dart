import "package:flutter/material.dart";
import "package:petrol_indicator/models/user.dart";
import "package:petrol_indicator/screens/auth/authWrapper.dart";
import "package:petrol_indicator/screens/auth/signUp.dart";
import "package:petrol_indicator/screens/home/home.dart";
import "package:provider/provider.dart";

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return user != null ? const Home() : const AuthWrapper();

  }
}
