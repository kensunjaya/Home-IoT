import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/firestore.dart';
import 'package:home_iot/pages/drawer.dart';
import 'package:vibration/vibration.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  late CloudFirestoreService service;

  late Map<String, dynamic>? userData = {};

  bool _isInitialized = false;

  Future<void> fetchDevice() async {
    userData = await service.get('users', Auth().currentUser!.email.toString());
    print(userData);
  }

  @override
  void initState() {
    super.initState();
    service = CloudFirestoreService(FirebaseFirestore.instance);
    _initializeAsync(); 
  }

  Future<void> _initializeAsync() async {
    await fetchDevice();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text('Loading ..', style: GoogleFonts.nunito(fontSize: 24)),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: GoogleFonts.nunito()), centerTitle: true),
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                leading: Icon(Icons.fingerprint_rounded, size: 36),
                title: Text('Biometric Authentication', style: GoogleFonts.nunito()),
                trailing: Switch(
                  value: userData!['profile']['biometric_auth'],
                  onChanged: (value) async {
                    Vibration.vibrate(duration: 50);
                    userData!['profile']['biometric_auth'] = value;
                    await service.update('users', Auth().currentUser!.email.toString(), {
                      'profile': userData!['profile']
                    });
                    setState(() {
                      userData!['profile']['biometric_auth'] = value;
                    });
                  },
                ),
              ),
            ]
          ),
        )
      )
    );
  }
}