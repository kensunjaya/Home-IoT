import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonFields extends StatelessWidget {
  ButtonFields({super.key});

  final TextEditingController buttonActionURL = TextEditingController();
  final TextEditingController buttonLabel = TextEditingController();
  final TextEditingController buttonActionOnLongPressURL = TextEditingController();

  Map<String, dynamic>? getText() {
    if (buttonActionURL.text.isEmpty || buttonLabel.text.isEmpty) {
      return null;
    }
    return {'button': 
      {
        'label': buttonLabel.text,
        'action': buttonActionURL.text,
        'onLongPress': buttonActionOnLongPressURL.text,
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
            controller: buttonActionURL,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Action URL (tap)",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: buttonActionOnLongPressURL,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Action URL (long press)",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: buttonLabel,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Label",
            )
          )
        ),
      ],
    );
  }
}