import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/pages/drawer.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.nunito()), centerTitle: true),
      drawer: AppDrawer(),
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}