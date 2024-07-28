import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/add_gate.dart';
import 'package:home_iot/firestore.dart';

class AddDevice extends StatefulWidget {
  const AddDevice({super.key});
  @override
  State<AddDevice> createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  static const List<String> typeList = <String>['Gate', 'Lamps'];
  String dropdownValue = typeList.first;
  CloudFirestoreService? service;

  GateFields gateFields = GateFields();

  void handleAddAction(Map<String, dynamic> data) {
    service?.update('users', Auth().currentUser!.email.toString(), data);
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
        title: Text('Add Device'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
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

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print(gateFields.getText());
                      handleAddAction(gateFields.getText());
                    },
                    child: Text('Add Gate'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
