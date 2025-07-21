import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vibration/vibration.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  late CloudFirestoreService service;
  late Map<String, dynamic>? userData = {};

  // Future<void> fetchDevice() async {
  //   userData = await service.get('users', Auth().currentUser!.email.toString());
  // }


  @override
  Widget build(BuildContext context) {
    void routeToAddDevice() async {
      // await fetchDevice();
      Navigator.pushReplacementNamed(context, '/devices');
    }
    
    return Drawer(
        width: 205,
        backgroundColor: Theme.of(context).canvasColor,
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
              title: Text('Home', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard_customize_rounded),
              title: Text('My Widgets', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () async {
                final LocalAuthentication auth = LocalAuthentication();
                bool canAuthenticate = false;

                try {
                  canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
                } catch (e) {
                  CustomToast(context).showToast('Error checking biometric support', Icons.error_rounded);
                  print('Error checking biometric support: $e');
                }

                // authentication using biometric
                if (canAuthenticate) {
                  try {
                    await auth.authenticate(
                      localizedReason: 'Authenticate using biometrics',
                      options: const AuthenticationOptions(),
                    ).then((authenticated) {
                      if (authenticated) {
                        Navigator.pushReplacementNamed(context, '/devices');
                      }
                    });
                  } catch (e) {
                    print(e);
                    routeToAddDevice();
                    Vibration.vibrate(duration: 500);
                  } 
                }
                else {
                  routeToAddDevice();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts_rounded),
              title: Text('My Account', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/account');
              },
            )
          ],
        )
      );
  }
}