import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoStreamFields extends StatelessWidget {
  VideoStreamFields({super.key});

  final TextEditingController videoStreamURL = TextEditingController();
  final TextEditingController videoStreamLabel = TextEditingController();
  final TextEditingController videoStreamAspectHorizontal = TextEditingController();
  final TextEditingController videoStreamAspectVertical = TextEditingController();

  Map<String, dynamic>? getText() {
    if (videoStreamURL.text.isEmpty || videoStreamLabel.text.isEmpty) {
      return null;
    }
    return {'video_stream': 
      {
        'label': videoStreamLabel.text,
        'url': videoStreamURL.text,
        "aspect_ratio": {
          'horizontal': videoStreamAspectHorizontal.text.isEmpty ? 4 : int.parse(videoStreamAspectHorizontal.text),
          'vertical': videoStreamAspectVertical.text.isEmpty ? 3 : int.parse(videoStreamAspectVertical.text)
        }
      }
    };
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Text(
          "Aspect Ratio (optional)",
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            Expanded(
              child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextField(
                style: GoogleFonts.nunito(),
                controller: videoStreamAspectHorizontal,
                keyboardType: TextInputType.number,
                maxLength: 2,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Horizontal",
                ),
              ),
              ),
            ),
            Text(":", style: GoogleFonts.nunito(fontSize: 24)),
            Expanded(
              child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextField(
                style: GoogleFonts.nunito(),
                controller: videoStreamAspectVertical,
                keyboardType: TextInputType.number,
                maxLength: 2,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Vertical",
                ),
              ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}