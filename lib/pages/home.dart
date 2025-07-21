import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_iot/pages/add_device.dart';
import 'package:home_iot/pages/drawer.dart';
import 'package:home_iot/utils/network_utils.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';


class HomePage extends StatefulWidget {
  // ask for biometric auth only if it's the initial page
  final bool initialPage;

  const HomePage({super.key, required this.initialPage});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late CloudFirestoreService service;
  late VlcPlayerController _vlcViewController = VlcPlayerController.network(
    'https://example.com/placeholder', // Placeholder URL
    hwAcc: HwAcc.full,
    autoPlay: false,
    options: VlcPlayerOptions(
      advanced: VlcAdvancedOptions([
        VlcAdvancedOptions.networkCaching(1500),
      ]),
    )
  );
  late Map<String, dynamic>? userData = {};
  late List devices = [];
  late List lamps = [];

  String loadingMessage = 'Loading';
  int videoStreamIndex = 0;
  int gateIndex = 0;
  bool _isAuthenticated = false;
  final bool _autoAspectRatio = GetStorage().read('auto_aspect_ratio') == "false" ? false : true;
  bool _isInitialized = false;
  // bool _isSwiping = false;
  bool _isOwner = true;

  void initStatus() {
    for (var device in devices) {
      fetchStatus(device['status_url']).then((value) {
        setState(() {
          device['status'] = value;
        });
      });
    }
  }

  void initMultipleLampsStatus() {
    for (var lamp in lamps) {
      fetchStatusWithDelimiter(lamp['status_url'], lamp['delimiter']).then((value) {
        setState(() {
          lamp['status'] = value;
        });
      });
    }
  }

  Future<void> fetchDevice() async {
    userData = await service.get('users', Auth().currentUser!.email.toString());
    if ((userData!['profile']['organization'].isNotEmpty && !userData!['profile']['organization']['isOwner']) && userData!['profile']['useOrganization']) {
      _isOwner = false;
      userData = await service.fetchOrganizationData(userData!['profile']['organization']['ref'] as DocumentReference);
    }
    else if (userData!['profile']['organization'].isNotEmpty && !userData!['profile']['organization']['isOwner']) {
      _isOwner = false;
    }
    devices = userData?['lamps'] ?? [];
    lamps = userData?['multiple_lamps'] ?? [];
    if (lamps.isNotEmpty) {
      initMultipleLampsStatus();
    }
    if (devices.isNotEmpty) {
      initStatus();
    }
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    service = CloudFirestoreService(FirebaseFirestore.instance);
    _initializeAsync();
  }

  Future<void> _showInvitationDialog(String sender, String organizationName, String username) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hi, $username', style: GoogleFonts.nunito()),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$sender has invited you to be part of $organizationName.', style: GoogleFonts.nunito()),
                Text('Tapping accept will allow you to access their exclusive widgets.', style: GoogleFonts.nunito()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Reject', style: GoogleFonts.nunito(textStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16))),
              onPressed: () async {
                userData!['profile']['invitation'] = {};
                await service.update('users', Auth().currentUser!.email.toString(), {
                  'profile': userData!['profile']
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () async {
                try {
                  Map<String, dynamic>? senderData = await service.get('users', sender);
                  Map<String, dynamic> temp = senderData!['profile'];
                  temp['organization']['members'].add(Auth().currentUser!.email.toString());
                  await service.update('users', sender, {
                    'profile': temp
                  });
                  userData!['profile']['organization'] = {
                    'label': organizationName,
                    'isOwner': false,
                    'ref': FirebaseFirestore.instance.collection('users').doc(sender)
                  };
                  userData!['profile']['invitation'] = {};
                  userData!['profile']['useOrganization'] = true;
                  await service.update('users', Auth().currentUser!.email.toString(), {
                    'profile': userData!['profile']
                  });
                  CustomToast(context).showToast('You are now part of $organizationName', Icons.check_rounded);
                } catch (e) {
                  print(e);
                } 
                Navigator.of(context).pop();
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(initialPage: false)));
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _initializeAsync() async {
    await fetchDevice();

    if (userData!['profile']['biometric_auth']) {
      final LocalAuthentication auth = LocalAuthentication();
      bool canAuthenticate = false;

      try {
        canAuthenticate = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      } catch (e) {
        CustomToast(context).showToast('Error checking biometric support', Icons.error_rounded);
        print('Error checking biometric support: $e');
      }

      // authentication using biometric
      if (canAuthenticate && widget.initialPage) {
        setState(() {
          loadingMessage = 'Waiting for authentication ..';
        });
        try {
          _isAuthenticated = await auth.authenticate(
            localizedReason: 'Authenticate using biometrics',
            options: const AuthenticationOptions(),
          );
        } catch (e) {
          print(e);
          Vibration.vibrate(duration: 1000);
          CustomToast(context).showToast("Cannot find any biometric devices", Icons.error_rounded);
          _isAuthenticated = true;
        }
        
      }
      else {
        setState(() {
          _isAuthenticated = true;
        });
      }
    }
    else {
      setState(() {
        _isAuthenticated = true;
      });
    }

    
    WidgetsBinding.instance.addObserver(this);
    _initializeVlcPlayer();
    _vlcViewController.initialize();
    setState(() {
      _isInitialized = true;
    });
    if (userData!['profile']['invitation'].isNotEmpty) {
      _showInvitationDialog(userData!['profile']['invitation']['sender'], userData!['profile']['invitation']['organization'], userData!['profile']['username']);
    }
  }

  Timer? _pollingTimer;


  void _initializeVlcPlayer() {
    if (userData?['video_stream']?[videoStreamIndex]?['url'] != null) {
      final newUrl = userData!['video_stream'][videoStreamIndex]['url'];
      if (_vlcViewController.value.isInitialized) {
        _vlcViewController.setMediaFromNetwork(newUrl);
        _vlcViewController.play();
      } else {
        bool isHlsStream = newUrl.endsWith('.m3u8');
        _vlcViewController = VlcPlayerController.network(
          newUrl,
          hwAcc: HwAcc.full,
          autoPlay: true,
          options: VlcPlayerOptions(
            advanced: VlcAdvancedOptions([
              VlcAdvancedOptions.networkCaching(isHlsStream ? 5000 : 1000),
            ]),
            rtp: VlcRtpOptions([
              VlcRtpOptions.rtpOverRtsp(isHlsStream ? true : false),
            ]),
          ),
        );
        if (isHlsStream) {
          _pollingTimer = Timer.periodic(Duration(milliseconds: 1800), (timer) {
            _vlcViewController.stop();
            _vlcViewController.play();
          });
        }

        
        _vlcViewController.initialize().then((_) {
          if (_vlcViewController.value.isInitialized) {
            _vlcViewController.play();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _vlcViewController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_vlcViewController.value.isInitialized) {
        _vlcViewController.stop();
        _vlcViewController.setMediaFromNetwork(userData!['video_stream'][videoStreamIndex]['url']);
        _vlcViewController.play();
      } else {
        _initializeVlcPlayer(); // Reinitialize the player
      }
    }
    else if (state == AppLifecycleState.paused) {
      _vlcViewController.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(loadingMessage, style: GoogleFonts.nunito(fontSize: 24)),
              ),
              CircularProgressIndicator(),
            ],
          ),
        )
      );
    }

    if (userData!.keys.length < 2) {
      return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          actions: [
            if (userData!['profile']['organization'].isNotEmpty && !_isOwner)
            IconButton(
              icon: Icon(Icons.swap_horiz_rounded),
              onPressed: () {
                setState(() async {
                  Map<String, dynamic>? temp = await service.get('users', Auth().currentUser!.email.toString());
                  temp!['profile']['useOrganization'] = !temp['profile']['useOrganization'];
                  await service.update('users', Auth().currentUser!.email.toString(), {
                    'profile': temp['profile']
                  });
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(initialPage: false)));
                });
              },
            ),
          ],
        ),
        
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(fontSize: 24),
                      children: [
                        TextSpan(text: "Hello, ", style: GoogleFonts.nunito(fontWeight: FontWeight.normal, color: Colors.black)),
                        TextSpan(text: "${userData!['profile']!['username']}", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 40, left: 16, right: 16),
                child: Text("Let's get started with adding widgets", style: GoogleFonts.nunito(fontSize: 24)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 50),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevice(userData: userData!)));
                },
                child: Text('Add Widgets', style: GoogleFonts.nunito()),
              ),
            ],
          ),
        )
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(userData?['video_stream']?[videoStreamIndex]?['label'] ?? userData?['profile']['header'], style: GoogleFonts.nunito()), 
        centerTitle: true,
        actions: [
          if (userData!['profile']['organization'].isNotEmpty && !_isOwner)
          IconButton(
            icon: Icon(Icons.swap_horiz_rounded),
            onPressed: () {
              setState(() async {
                Map<String, dynamic>? temp = await service.get('users', Auth().currentUser!.email.toString());
                temp!['profile']['useOrganization'] = !temp['profile']['useOrganization'];
                await service.update('users', Auth().currentUser!.email.toString(), {
                  'profile': temp['profile']
                });
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(initialPage: false)));
              });
            },
          ),
        ],
      ),

      drawer: AppDrawer(),
      body: ListView(
        children: [ 
          if (userData!.containsKey('video_stream'))
            Padding(
              padding: EdgeInsets.all(10),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails details) {
                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                    details.globalPosition.dx,
                    details.globalPosition.dy,
                  ),
                  items: userData?['video_stream'].map<PopupMenuEntry<int>>((vid) {
                    return PopupMenuItem<int>(
                      value: userData?['video_stream'].indexOf(vid),
                      child: Text(vid['label'], style: GoogleFonts.nunito(fontSize: 18)),
                    );
                  }).toList(),
                ).then((index) {
                  if (index != null) {
                    setState(() {
                      videoStreamIndex = index;
                    });
                    _initializeVlcPlayer();
                  }
                });
              },
                // onPanUpdate: (details) {
                //   if (_isSwiping) return;
                //   _isSwiping = true;
                //   Vibration.vibrate(duration: 50);

                //   if (details.delta.dx > 0 && videoStreamIndex > 0) {
                //     setState(() {
                //       videoStreamIndex--;
                //     });
                //     _initializeVlcPlayer();

                //   } else if (details.delta.dx < 0 && videoStreamIndex < userData?['video_stream']?.length - 1) {
                //     setState(() {
                //       videoStreamIndex++;
                //     });
                //     _initializeVlcPlayer();
                //   }
                //   Future.delayed(Duration(milliseconds: 500), () {
                //     _isSwiping = false;
                //   });
                // },
                child: 
                IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: VlcPlayer(
                      controller: _vlcViewController,
                      aspectRatio: _autoAspectRatio && userData?['video_stream']?[videoStreamIndex]?['aspect_ratio'] != null
                        ? userData!['video_stream'][videoStreamIndex]['aspect_ratio']['horizontal'] / 
                          userData!['video_stream'][videoStreamIndex]['aspect_ratio']['vertical']
                        : (4 / 3),
                      placeholder: Center(child: CircularProgressIndicator()),
                    ),
                  )
                )
              )
            ),

          if (userData!.containsKey('gate'))
            Center(
              child: Container(
                margin: EdgeInsets.all(10),
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox.expand(
                          child: ElevatedButton(
                            onPressed: () async {
                              Vibration.vibrate(duration: 100);
                              // play sound
                              CustomToast(context).showToast("Opening Gate", Icons.lock_open_rounded);
                              await http.get(Uri.parse(userData?['gate'][gateIndex]['open_url']));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, double.infinity),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Icon(Icons.lock_open_rounded, size: 32),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox.expand(
                          child: ElevatedButton(
                            onPressed: () async {
                              Vibration.vibrate(duration: 100);
                              CustomToast(context).showToast("Toggled Gate", Icons.stop_rounded);
                              await http.get(Uri.parse(userData?['gate'][gateIndex]['toggle_url']));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, double.infinity),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Icon(Icons.stop_rounded, size: 32),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox.expand(
                          child: ElevatedButton(
                            onPressed: () async {
                              Vibration.vibrate(duration: 100);
                              CustomToast(context).showToast("Closing Gate", Icons.lock_rounded);
                              await http.get(Uri.parse(userData?['gate'][gateIndex]['close_url']));
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, double.infinity),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Icon(Icons.lock_rounded, size: 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),

          if (userData!.containsKey('multiple_lamps'))
          ...(userData?['multiple_lamps'] ?? []).map((lamps) => 
            SizedBox(
              height: (110 * (lamps['label'].length / 2).ceil()).toDouble(),
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: lamps['label'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                  ),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 50, // Fixed height
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10), 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                lamps['status'][index] ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                                size: 24,
                                color: Theme.of(context).primaryColor,
                              ),
                              Text(lamps['label'][index], style: GoogleFonts.nunito(fontSize: 14)),
                              Transform.scale(scale: 0.75, child: Switch(value: lamps['status'][index] ?? false,
                              onChanged: (bool value) {
                                Vibration.vibrate(duration: 30);
                                CustomToast(context).showToast("Turned ${value ? 'on' : 'off'} Lampu ${lamps['label'][index]}", Icons.lightbulb_outline_rounded);
                                setState(() async {
                                  lamps['status'][index] = value;
                                  if (value) {
                                    await http.get(Uri.parse(lamps['on_url'][index]));
                                  }
                                  else {
                                    await http.get(Uri.parse(lamps['off_url'][index]));
                                  }
                                  initMultipleLampsStatus();
                                });
                              }))
                            ],
                          )
                        
                      ),
                    ),
                  ),
                ),
              )
            )
          ).toList(),
            

          if (userData!.containsKey('lamps'))
            SizedBox(
              height: (110 * (devices.length / 2).ceil()).toDouble(),
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: devices.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                  ),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 50, // Fixed height
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10), 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, size: 24),
                              Text(devices[index]['label'], style: GoogleFonts.nunito(fontSize: 14)),
                              Transform.scale(scale: 0.75, child: Switch(value: devices[index]['status'],
                              onChanged: (bool value) {
                                CustomToast(context).showToast("Turned ${value ? 'on' : 'off'} Lampu ${devices[index]['label']}", Icons.lightbulb_outline_rounded);
                                setState(() async {
                                  devices[index]['status'] = value;
                                  if (value) {
                                    await http.get(Uri.parse(devices[index]['on_url']));
                                  }
                                  else {
                                    await http.get(Uri.parse(devices[index]['off_url']));
                                  }
                                  initStatus();
                                });
                              }))
                            ],
                          )
                        
                      ),
                    ),
                  ),
                ),
              )
          ),
          if (userData!.containsKey('button'))
              SizedBox(
                
                height: ((userData!['button'].length / 3).ceil() * 100).toDouble(),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: userData!['button'].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      height: 50, // Fixed height
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10), 
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, double.infinity),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Colors.grey, 
                            // backgroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            Vibration.vibrate(duration: 100);
                            CustomToast(context).showToast("Button ${userData!['button'][index]['label']} pressed", Icons.stop_rounded);
                            await http.get(Uri.parse(userData!['button'][index]['action']));
                          },
                          onLongPress: () async {
                            Vibration.vibrate(duration: 250);
                            CustomToast(context).showToast("Button ${userData!['button'][index]['label']} long pressed", Icons.stop_rounded);
                            await http.get(Uri.parse(userData!['button'][index]['onLongPress']));
                          },
                          child: Text(userData!['button'][index]['label'], style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                        )
                      ),
                    ),
                  ),
                ),
              ),
            
        ],
      ),
    );
  }
}
