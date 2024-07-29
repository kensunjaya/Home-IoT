import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';

class AddOrganization extends StatefulWidget {
  final Map<String, dynamic> userData;
  const AddOrganization({super.key, required this.userData});

  @override
  State<AddOrganization> createState() => _AddOrganizationState();
}

class _AddOrganizationState extends State<AddOrganization> {
  final TextEditingController organizationName = TextEditingController();
  final TextEditingController memberEmail = TextEditingController();
  CloudFirestoreService? service;

  @override
  void initState() {
    super.initState();
    service = CloudFirestoreService(FirebaseFirestore.instance);
    if (widget.userData['profile']['organization'].isNotEmpty) {
      organizationName.text = widget.userData['profile']['organization']['label'];
    }
  }

  void postData() async {
    if (organizationName.text.isEmpty || memberEmail.text.isEmpty) {
      if (organizationName.text.isEmpty) {
        CustomToast(context).showToast('Organization name cannot be empty', Icons.error_rounded);
      }
      else {
        CustomToast(context).showToast('Member cannot be empty', Icons.error_rounded);
      }
      return;
    }

    if (memberEmail.text == Auth().currentUser!.email.toString()) {
      CustomToast(context).showToast('You cannot add yourself', Icons.error_rounded);
      return;
    }

    List userList = await service?.fetchUsers('users') as List;
    if (!userList.contains(memberEmail.text)) {
      CustomToast(context).showToast('User not found', Icons.error_rounded);
      return;
    }
    Map<String, dynamic> temp = await service?.get('users', memberEmail.text) as Map<String, dynamic>;
    try {
      if (widget.userData['profile']['organization'].isNotEmpty) {

        // Create an invitation to recipient's account
        temp['profile']['invitation'] = {
          'organization': organizationName.text,
          'sender': Auth().currentUser!.email.toString(),
        };

        // send the invitation
        await service?.update('users', memberEmail.text, {
          'profile': temp['profile']
        });

        CustomToast(context).showToast('Invitation sent', Icons.check_rounded);
      }
      else {
        widget.userData['profile']['organization'] = {
          'label': organizationName.text,
          'members': [],
          'isOwner': true,
        };
        await service?.update('users', Auth().currentUser!.email.toString(), {
          'profile': widget.userData['profile']
        });

        // Create an invitation to recipient's account
        temp['profile']['invitation'] = {
          'organization': organizationName.text,
          'sender': Auth().currentUser!.email.toString(),
        };

        // send the invitation
        await service?.update('users', memberEmail.text, {
          'profile': temp['profile']
        });
        CustomToast(context).showToast('Organization created successfully', Icons.check_rounded);
      }
    } catch (e) {
      CustomToast(context).showToast(e.hashCode.toString(), Icons.error_rounded);
    } finally {
      CustomToast(context).showToast('Organization added successfully!', Icons.check_rounded);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushNamed(context, '/account');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Organization', style: GoogleFonts.nunito(), textAlign: TextAlign.center)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TextField(
                    readOnly: widget.userData['profile']['organization'].isNotEmpty,
                    style: GoogleFonts.nunito(),
                    controller: organizationName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Organization Name",
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextField(
                    style: GoogleFonts.nunito(),
                    controller: memberEmail,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter a user's email to add",
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        postData();
                      },
                      child: Text('Add to my organization', style: GoogleFonts.nunito()),
                    ),
                  )
                ),
              ],
            )
          )
        )
      )
    );  
  }
}