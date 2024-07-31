import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:home_iot/pages/account.dart';
import 'package:home_iot/pages/devices.dart';
import 'package:home_iot/pages/home.dart';
import 'package:home_iot/pages/login.dart';
import 'package:home_iot/pages/register.dart';
import 'package:home_iot/pages/settings.dart';
import 'package:home_iot/widget_tree.dart';
import 'theme_notifier.dart'; // Import the ThemeNotifier

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: HomeIoT(),
    ),
  );
}

class HomeIoT extends StatelessWidget {
  const HomeIoT({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Home IoT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeNotifier.seedColor,
          brightness: Brightness.light,
        ),
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
