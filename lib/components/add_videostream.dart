import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoStreamFields extends StatelessWidget {
  VideoStreamFields({super.key});

  final TextEditingController videoStreamURL = TextEditingController();
  final TextEditingController videoStreamLabel = TextEditingController();

  Map<String, dynamic>? getText() {
    if (videoStreamURL.text.isEmpty || videoStreamLabel.text.isEmpty) {
      return null;
    }
    return {'video_stream': 
      {
        'label': videoStreamLabel.text,
        'url': videoStreamURL.text,
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
            controller: videoStreamURL,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Stream URL",
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: videoStreamLabel,
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