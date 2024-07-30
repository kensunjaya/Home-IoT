import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GateFields extends StatelessWidget {
  GateFields({super.key});

  final TextEditingController gateNameController = TextEditingController();
  final TextEditingController gateToggleURL = TextEditingController();
  final TextEditingController gateOpenURL = TextEditingController();
  final TextEditingController gateCloseURL = TextEditingController();

  Map<String, dynamic>? getText() {
    if (gateNameController.text.isEmpty || gateOpenURL.text.isEmpty || gateCloseURL.text.isEmpty) {
      return null;
    }
    return {'gate': 
      {
        'label': gateNameController.text,
        'toggle_url': gateToggleURL.text,
        'open_url': gateOpenURL.text,
        'close_url': gateCloseURL.text,
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
            controller: gateNameController,
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
            controller: gateOpenURL,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "URL to open the gate",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: gateCloseURL,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "URL to close the gate",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: gateToggleURL,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "URL to toggle the gate (optional)",
            )
          )
        ),
      ],
    );
  }
}