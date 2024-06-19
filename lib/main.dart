import 'package:flutter/material.dart';
import 'package:surya4/pages/dasboard.dart';
import 'package:surya4/pages/login.dart';
// import 'package:surya4/pages/produk.dart';

void main() {
  runApp(MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({Key? key}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home : WelcomePage(),
      routes: {
        '/login': (BuildContext context) => const LandingPage1(),
        // '/landing': (BuildContext context) => new LandingPage(),
      },
    );
  }
}