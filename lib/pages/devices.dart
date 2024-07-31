import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/firestore.dart';
import 'package:home_iot/pages/add_device.dart';
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
        title: Text(key.toUpperCase().replaceAll('_', ' '), style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        children: value.map((item) {
          if (item is Map) {
            return ExpansionTile(
              title: Text('${item['label']}', style: GoogleFonts.nunito()),
              children: item.entries.where((entry) => entry.key != 'label' && entry.key != 'status').map((entry) => buildKeyValueTile(entry.key, entry.value)).toList(),
            );
          } else {
            return ListTile(
              title: Text('${item['label']}', style: GoogleFonts.nunito()),
              subtitle: Text(item.toString(), style: GoogleFonts.nunito()),
            );
          }
        }).toList(),
      );
    } else if (value is Map) {
      return ExpansionTile(
        title: Text(key.toUpperCase().replaceAll('_', ' '), style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        children: value.entries.map((entry) => buildKeyValueTile(entry.key, entry.value)).toList(),
      );
    } else {
      return ListTile(
        title: Text(key.toUpperCase().replaceAll('_', ' '), style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
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
      appBar: AppBar(title: Text('My Widgets', style: GoogleFonts.nunito()), centerTitle: true),
      drawer: const AppDrawer(),
      body: userData!.keys.length > 1 ?
      ListView(
        children: [
          Column(
            children: userData!.entries
              .where((entry) => entry.key != 'profile' && entry.key != 'header')
              .map((entry) => buildKeyValueTile(entry.key, entry.value))
              .toList(),
            ),
          Padding(padding: EdgeInsets.all(16.0), 
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevice(userData: userData!)));
              },
              child: Text('Add another widget', style: GoogleFonts.nunito()),
            )
          )
        ]
      )
      :
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Text("No widgets found", style: GoogleFonts.nunito(fontSize: 24)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(150, 50),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevice(userData: userData!)));
              },
              child: Text('Add a widget', style: GoogleFonts.nunito()),
            )
          ],
        )
      )
    );
  }
}
