import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_iot/pages/account.dart';
import 'package:home_iot/pages/devices.dart';
import 'package:home_iot/pages/home.dart';
import 'package:home_iot/pages/login.dart';
import 'package:home_iot/pages/register.dart';
import 'package:home_iot/pages/settings.dart';
import 'package:home_iot/widget_tree.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomeIoT());
}

class HomeIoT extends StatelessWidget {
  const HomeIoT({super.key});
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WidgetTree(),
      routes: {
        '/home': (context) => HomePage(initialPage: false),
        '/settings': (context) => SettingsPage(),
        '/account': (context) => AccountPage(),
        '/widget_tree': (context) => WidgetTree(),
        '/devices': (context) => MyDevices(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}