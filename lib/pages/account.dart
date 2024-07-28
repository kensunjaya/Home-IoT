import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';
import 'package:home_iot/pages/drawer.dart';

class AccountPage extends StatefulWidget {
  AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with WidgetsBindingObserver {
  late CloudFirestoreService service;

  late Map<String, dynamic>? userData = {};

  bool _isInitialized = false;

  Future<void> signout(BuildContext context) async {
    try {
      await Auth().signOut();
      Navigator.pushReplacementNamed(context, '/widget_tree');
    }
    catch (e) {
      CustomToast(context).showToast(e.hashCode.toString(), Icons.error_rounded);
    }
  }

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
      appBar: AppBar(title: Text('Account Management', style: GoogleFonts.nunito()), centerTitle: true),
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                leading: Icon(Icons.email_rounded, size: 36),
                title: Text('Email', style: GoogleFonts.nunito()),
                subtitle: Text(Auth().currentUser!.email.toString(), style: GoogleFonts.nunito()),
              ),
              ListTile(
                leading: Icon(Icons.person_rounded, size: 36),
                title: Text('Name', style: GoogleFonts.nunito()),
                subtitle: Text(userData?['profile']['username'], style: GoogleFonts.nunito()),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  signout(context);
                },
                child: Text('Sign Out', style: GoogleFonts.nunito()),
              )
            ]
          ),
        )
      )
    );
  }
}