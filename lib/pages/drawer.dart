import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        width: 225,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              child: SvgPicture.asset(
                'assets/logo.svg',
                height: 64,
                width: 64,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home_rounded),
              title: Text('Home', style: GoogleFonts.nunito()),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings', style: GoogleFonts.nunito()),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard_customize_rounded),
              title: Text('My Widgets', style: GoogleFonts.nunito()),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/devices');
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts_rounded),
              title: Text('My Account', style: GoogleFonts.nunito()),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/account');
              },
            )
          ],
        )
      );
  }
}