import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LampFields extends StatelessWidget {
  LampFields({super.key});

  final TextEditingController lampLabel = TextEditingController();
  final TextEditingController lampStatus = TextEditingController();
  final TextEditingController lampOn = TextEditingController();
  final TextEditingController lampOff = TextEditingController();

  Map<String, dynamic> getText() {
    return {'lamps': 
      {
        'label': lampLabel.text,
        'status_url': lampStatus.text,
        'on_url': lampOn.text,
        'off_url': lampOff.text,
        'status': false,
      }
    };
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: lampLabel,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Label",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: lampStatus,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Device status URL",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: lampOn,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "URL to turn on the lamp",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: lampOff,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "URL to turn off the lamp",
            )
          )
        ),
      ],
    );
  }
}