import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';


class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  CloudFirestoreService? service;

  Future<void> register(BuildContext context) async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      service?.add('users', emailController.text,
      {'profile': 
        {
          'email': emailController.text,
          'password': passwordController.text,
          'username': usernameController.text,
        },
        'header': "Home"
      });
      CustomToast(context).showToast('Account created successfully!', Icons.check_rounded);
      Navigator.pushReplacementNamed(context, '/home');
    }
    catch (e) {
      CustomToast(context).showToast(e.toString(), Icons.error_rounded);
    }
  }

  @override
  void initState() {
    // Initialize an instance of Cloud Firestore
    service = CloudFirestoreService(FirebaseFirestore.instance);
    super.initState();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Create an account', style: GoogleFonts.nunito(fontSize: 24), textAlign: TextAlign.left),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: TextField(
                  style: GoogleFonts.nunito(),
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your name..",
                  )
                )
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  style: GoogleFonts.nunito(),
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your email..",
                  )
                )
              ),
              
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  obscureText: true,
                  style: GoogleFonts.nunito(),
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your password..",
                  )
                )
              ),
              Padding(padding: EdgeInsets.only(bottom: 16), 
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.black)),
                    children: <TextSpan>[
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign In',
                        
                        style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.blue)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                      ),
                    ],
                  ),
                )
              ),
              
            
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  register(context);
                },
                child: Text('Sign Up', style: GoogleFonts.nunito()),
              )
            ]
          ),
        )
      )
    );
  }
}