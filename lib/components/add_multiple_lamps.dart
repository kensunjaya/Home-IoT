import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/components/custom_button.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/utils/network_utils.dart';

class MultipleLampFields extends StatefulWidget {
  const MultipleLampFields({super.key});

  @override
  MultipleLampFieldsState createState() => MultipleLampFieldsState();
}

class MultipleLampFieldsState extends State<MultipleLampFields> {
  int lampCount = 0; // Change this to the number of lamps you want to add
  late List<TextEditingController> lampLabels = List.generate(lampCount, (_) => TextEditingController());
  late List<TextEditingController> lampOns = List.generate(lampCount, (_) => TextEditingController());
  late List<TextEditingController> lampOffs = List.generate(lampCount, (_) => TextEditingController());
  final TextEditingController lampStatus = TextEditingController();
  final TextEditingController delimiter = TextEditingController();

  Map<String, dynamic>? getText() {
    if (lampLabels.any((controller) => controller.text.isEmpty) ||
        lampOns.any((controller) => controller.text.isEmpty) ||
        lampOffs.any((controller) => controller.text.isEmpty) ||
        lampStatus.text.isEmpty ||
        delimiter.text.isEmpty || lampCount == 0) {
      return null;
    }
    return {
      'multiple_lamps': {
        'label': lampLabels.map((controller) => controller.text).toList(),
        'status_url': lampStatus.text,
        'on_url': lampOns.map((controller) => controller.text).toList(),
        'off_url': lampOffs.map((controller) => controller.text).toList(),
        'delimiter': delimiter.text,
        'status': List.filled(lampCount, false),
      }
    };
  }

  void checkButtonPressed() async {
    // fetch the device status url with the delimiter
    if (lampStatus.text.isEmpty || delimiter.text.isEmpty) {
      CustomToast(context).showToast('Please fill in all required fields!', Icons.error_rounded);
      return;
    }
    final lampStatuses = await fetchStatusWithDelimiter(lampStatus.text, delimiter.text);
    print(lampStatuses);
    if (lampStatuses.isEmpty) {
      CustomToast(context).showToast('Wrong URL or delimiter!', Icons.error_rounded);
    }
    lampCount = lampStatuses.length;
    setState(() {
      lampLabels = List.generate(lampCount, (_) => TextEditingController());
      lampOns = List.generate(lampCount, (_) => TextEditingController());
      lampOffs = List.generate(lampCount, (_) => TextEditingController());
    });
  }

  @override
  void dispose() {
    for (var controller in lampLabels) {
      controller.dispose();
    }
    for (var controller in lampOns) {
      controller.dispose();
    }
    for (var controller in lampOffs) {
      controller.dispose();
    }
    lampStatus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: lampStatus,
            enabled: lampCount == 0,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Lamps status URL",
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            style: GoogleFonts.nunito(),
            controller: delimiter,
            enabled: lampCount == 0,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Delimiter",
            ),
          ),
        ),
        ...List.generate(lampCount, (i) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Lamp ${i + 1}",
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                style: GoogleFonts.nunito(),
                controller: lampLabels[i],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Label",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                style: GoogleFonts.nunito(),
                controller: lampOns[i],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "URL to turn on",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                style: GoogleFonts.nunito(),
                controller: lampOffs[i],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "URL to turn off",
                ),
              ),
            ),
          ],
        )),
        if (lampCount == 0)
          CustomButton(onPressed: checkButtonPressed, label: "Check Status")
      ],
    );
  }
}