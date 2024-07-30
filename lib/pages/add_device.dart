import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/add_button.dart';
import 'package:home_iot/components/add_gate.dart';
import 'package:home_iot/components/add_lamp.dart';
import 'package:home_iot/components/add_videostream.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';

class AddDevice extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AddDevice({super.key, required this.userData});
  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice>{
  static const List<String> typeList = <String>['Video Stream', 'Gate', 'Lamps', 'Button'];
  String dropdownValue = typeList.first;
  CloudFirestoreService? service;

  final GateFields gateFields = GateFields();
  final LampFields lampFields = LampFields();
  final VideoStreamFields videoStreamFields = VideoStreamFields();
  final ButtonFields buttonFields = ButtonFields();

  void handleAddAction(Map<String, dynamic>? data) {
    if (data == null) {
      CustomToast(context).showToast('Please fill in all required fields!', Icons.error_rounded);
      return;
    }
    try {
      final deviceData = widget.userData[data!.keys.first] ?? [];
      deviceData.add(data[data.keys.first]);
      service?.update('users', Auth().currentUser!.email.toString(), {
        data.keys.first: deviceData,
      });
      CustomToast(context).showToast('Widget added successfully!', Icons.check_rounded);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushNamed(context, '/devices');
    }
    catch (e) {
      print(e);
      CustomToast(context).showToast(e.hashCode.toString(), Icons.error_rounded);
    }
  }

  @override
  void initState() {
    super.initState();
    service = CloudFirestoreService(FirebaseFirestore.instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Widget', style: GoogleFonts.nunito(), textAlign: TextAlign.center),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(5),
                    style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.black, fontSize: 16)),
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_drop_down_rounded),
                    isExpanded: true,
                    underline: SizedBox(), // Remove the underline
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: typeList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),

                if (dropdownValue == 'Gate')
                  gateFields,
                if (dropdownValue == 'Lamps')
                  lampFields,
                if (dropdownValue == 'Video Stream')
                  videoStreamFields,
                if (dropdownValue == 'Button')
                  buttonFields,

                // if (widget.userData['profile']['organization']['isOwner'])
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        if (dropdownValue == 'Lamps') {
                          handleAddAction(lampFields.getText());
                        }
                        else if (dropdownValue == 'Gate') {
                          handleAddAction(gateFields.getText());
                        }
                        else if (dropdownValue == 'Video Stream') {
                          handleAddAction(videoStreamFields.getText());
                        }
                        else if (dropdownValue  == 'Button') {
                          handleAddAction(buttonFields.getText());
                        }
                      },
                      child: Text('Confirm add widget', style: GoogleFonts.nunito()),
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
