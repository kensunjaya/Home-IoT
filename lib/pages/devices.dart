import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/firestore.dart';
import 'package:home_iot/pages/drawer.dart';

class MyDevices extends StatefulWidget {
  const MyDevices({super.key});

  @override
  State<MyDevices> createState() => _MyDevicesState();
}

class _MyDevicesState extends State<MyDevices> with WidgetsBindingObserver {
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

  Widget buildKeyValueTile(String key, dynamic value) {
    if (value is List) {
      return ExpansionTile(
        title: Text(key.toUpperCase(), style: GoogleFonts.nunito()),
        children: value.map((item) {
          if (item is Map) {
            return ExpansionTile(
              title: Text('Lampu ${item['name']}', style: GoogleFonts.nunito()),
              children: item.entries.map((entry) => buildKeyValueTile(entry.key, entry.value)).toList(),
            );
          } else {
            return ListTile(
              title: Text('Lampu ${item['name']}', style: GoogleFonts.nunito()),
              subtitle: Text(item.toString(), style: GoogleFonts.nunito()),
            );
          }
        }).toList(),
      );
    } else if (value is Map) {
      return ExpansionTile(
        title: Text(key.toUpperCase(), style: GoogleFonts.nunito()),
        children: value.entries.map((entry) => buildKeyValueTile(entry.key, entry.value)).toList(),
      );
    } else {
      return ListTile(
        title: Text(key.toUpperCase(), style: GoogleFonts.nunito()),
        subtitle: Text(value.toString(), style: GoogleFonts.nunito()),
      );
    }
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
      appBar: AppBar(title: Text('My Devices', style: GoogleFonts.nunito()), centerTitle: true),
      drawer: const AppDrawer(),
      body: ListView(
        children: [
          Column(
            children: userData!.entries
              .where((entry) => entry.key != 'profile' && entry.key != 'header')
              .map((entry) => buildKeyValueTile(entry.key, entry.value))
              .toList(),
            ),
            Padding(padding: EdgeInsets.all(16.0), child:
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_device');
                },
                child: Text('Add another device', style: GoogleFonts.nunito()),
              )
            ),
        ]
      ),
    );
  }
}
