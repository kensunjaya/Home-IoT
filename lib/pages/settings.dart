import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/firestore.dart';
import 'package:home_iot/pages/drawer.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';
import 'package:home_iot/theme_notifier.dart'; // Import ThemeNotifier

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  late CloudFirestoreService service;
  late Map<String, dynamic>? userData = {};
  static const List<String> colorList = <String>['Cyan', 'Indigo', 'Blue', 'Red', 'Green', 'Yellow', 'Purple', 'Orange', 'Pink', 'Brown', 'Teal'];
  String colorValue = GetStorage().read('seed_color') ?? 'Cyan';

  bool _isInitialized = false;

  Future<void> fetchDevice() async {
    userData = await service.get('users', Auth().currentUser!.email.toString());
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

    final themeNotifier = Provider.of<ThemeNotifier>(context);

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
              ListTile(
                leading: Icon(Icons.color_lens_rounded, size: 36),
                title: Text('App Accent Color', style: GoogleFonts.nunito()),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(5),
                    style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                    value: colorValue,
                    icon: Icon(Icons.arrow_drop_down_rounded),
                    underline: SizedBox(),
                    onChanged: (String? newValue) {
                      setState(() {
                        colorValue = newValue!;
                      });
                      themeNotifier.setSeedColor(newValue!);
                    },
                    items: colorList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ]
          ),
        )
      )
    );
  }
}
