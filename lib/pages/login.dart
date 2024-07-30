import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:flutter/gestures.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  Future<void> signin(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      CustomToast(context).showToast('Please fill in all required fields!', Icons.error_rounded);
      return;
    }
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      CustomToast(context).showToast('Logged in successfully!', Icons.check_rounded);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'Your account is being suspended.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        default:
          errorMessage = 'Invalid credential.';
      }
      CustomToast(context).showToast(errorMessage, Icons.error_rounded);
    } catch (e) {
      CustomToast(context).showToast('An error occurred. Please try again.', Icons.error_rounded);
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
              Text('Sign In to your account', style: GoogleFonts.nunito(fontSize: 24), textAlign: TextAlign.left),
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
                  obscureText: true,
                  style: GoogleFonts.nunito(),
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // labelText: 'Password',
                    hintText: "Enter your password..",
                  )
                )
              ),

              Padding(padding: EdgeInsets.only(bottom: 16), 
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.black)),
                    children: <TextSpan>[
                      TextSpan(text: "Don't have an account yet? ", style: TextStyle(fontSize: 16)),
                      TextSpan(
                        text: 'Sign Up',
                        
                        style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w500)),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(context, '/register');
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