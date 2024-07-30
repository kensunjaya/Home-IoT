import 'package:flutter/material.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/pages/home.dart';
import 'package:home_iot/pages/login.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      // builder: (context, snapshot) => snapshot.hasData ? HomePage(initialPage: true) : LoginPage(),
      builder: (context, snapshot) => snapshot.hasData ? HomePage(initialPage: true) : LoginPage(),
    );
  }
}