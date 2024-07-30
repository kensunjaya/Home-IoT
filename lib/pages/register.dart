import 'package:firebase_auth/firebase_auth.dart';
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
    if (emailController.text.isEmpty || passwordController.text.isEmpty || usernameController.text.isEmpty || labelController.text.isEmpty) {
      CustomToast(context).showToast('Please fill in all required fields!', Icons.error_rounded);
      return;
    }
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      service?.add('users', emailController.text,
      {'profile': 
        {
          'email': emailController.text,
          'username': usernameController.text,
          'header': labelController.text,
          'organization': {},
          'invitation': {},
          'useOrganization': false,
        },
      });
      CustomToast(context).showToast('Account created successfully!', Icons.check_rounded);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An unknown error occurred.';
      }
      CustomToast(context).showToast(errorMessage, Icons.error_rounded);
    } catch (e) {
      CustomToast(context).showToast('An error occurred. Please try again.', Icons.error_rounded);
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
  TextEditingController labelController = TextEditingController();

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
                  style: GoogleFonts.nunito(),
                  controller: labelController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter your project title..",
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
                      TextSpan(text: 'Already have an account? ', style: TextStyle(fontSize: 16)),
                      TextSpan(
                        text: 'Sign In',
                        
                        style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w500)),
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