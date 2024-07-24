import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/pages/drawer.dart';

class AccountPage extends StatelessWidget {
  AccountPage({super.key});

  Future<void> signout(BuildContext context) async {
    try {
      await Auth().signOut();
      Navigator.pushReplacementNamed(context, '/widget_tree');
    }
    catch (e) {
      CustomToast(context).showToast(e.hashCode.toString(), Icons.error_rounded);
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Management', style: GoogleFonts.nunito()), centerTitle: true),
      drawer: AppDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Details', style: GoogleFonts.nunito(fontSize: 24), textAlign: TextAlign.left),


              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // minimumSize: Size(double.infinity, 50),
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