import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  Future<void> signin(BuildContext context) async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ).then(CustomToast(context).showToast('Logged in successfully!', Icons.check_rounded));
      Navigator.pushReplacementNamed(context, '/home');
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sign In', style: GoogleFonts.nunito(fontSize: 24), textAlign: TextAlign.left),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextField(
                  style: GoogleFonts.nunito(),
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // labelText: 'Email',
                    hintText: "Enter your email..",
                  )
                )
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  style: GoogleFonts.nunito(),
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // labelText: 'Password',
                    hintText: "Enter your password..",
                  )
                )
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  signin(context);
                },
                child: Text('Sign In', style: GoogleFonts.nunito()),
              )
            ]
          ),
        )
      )
    );
  }
}