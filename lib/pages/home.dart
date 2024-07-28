import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_iot/auth.dart';
import 'package:home_iot/components/custom_toast.dart';
import 'package:home_iot/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_iot/pages/add_device.dart';
import 'package:home_iot/pages/drawer.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser; // Import the html package
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:local_auth/local_auth.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late CloudFirestoreService service;
  late VlcPlayerController _vlcViewController;
  late Map<String, dynamic>? userData = {};
  late List devices = [];
  int gateIndex = 0;
  // bool _isAuthenticated = false;
  bool _isInitialized = false;

  Future<bool> fetchStatus(String url) async {
    var parsedUrl = Uri.parse(url);
    final httpPackageResponse = await http.get(parsedUrl);
    // Parse the HTML response
    var document = html_parser.parse(httpPackageResponse.body);
    // Extract the text content
    var textContent = document.body?.text ?? 'Error parsing response';
    if (textContent.trim() == '1') {
      return true;
    }
    else {
      return false;
    }
  }

  void initStatus() {
    for (var device in devices) {
      fetchStatus(device['status_url']).then((value) {
        setState(() {
          device['status'] = value;
        });
      });
    }
  }

  Future<void> fetchDevice() async {
    
    userData = await service.get('users', Auth().currentUser!.email.toString());
    devices = userData?['lamps'] ?? [];
    if (devices.isNotEmpty) {
      print("initializing status");
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

  Future<void> _initializeAsync() async {
  //   final LocalAuthentication auth = LocalAuthentication();
  // // ···
  //   final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  //   final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

  //   if (canAuthenticate) {
  //     try {
  //         _isAuthenticated = await auth.authenticate(
  //         localizedReason: 'Authenticate using biometrics',
  //         options: const AuthenticationOptions(biometricOnly: true),
  //       );
  //     }
  //     catch (e) {
  //       print(e);
  //       _isAuthenticated = true;
  //     }
      
  //   }
  //   else {
  //     setState(() {
  //       _isAuthenticated = true;
  //     });
  //   }

    await fetchDevice();
    WidgetsBinding.instance.addObserver(this);
    _initializeVlcPlayer();
    setState(() {
      _isInitialized = true;
    });
  }


  void _initializeVlcPlayer() {
    if (userData?['gate']?[gateIndex]['preview'] != null) {
      _vlcViewController = VlcPlayerController.network(
        userData?['gate'][gateIndex]['preview'],
        hwAcc: HwAcc.full,
        autoPlay: true,
        // options: VlcPlayerOptions(
        //   advanced: VlcAdvancedOptions(
        //   )
        // ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    _vlcViewController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _vlcViewController.play(); // Restart the stream when app resumes
    }
  }


  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text('Loading ..', style: GoogleFonts.nunito(fontSize: 24)),
              ),
              CircularProgressIndicator(),
            ],
          ),
        )
      );
    }

    if (userData!.keys.length < 3) {
      return Scaffold(
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
                child: Text("Get started with adding device connections", style: GoogleFonts.nunito(fontSize: 24)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevice(userData: userData!)));
                },
                child: Text('Add Device', style: GoogleFonts.nunito()),
              ),
            ],
          ),
        )
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(userData?['header'], style: GoogleFonts.nunito()), centerTitle: true),
      drawer: AppDrawer(),
      body: Column(
        children: [ 
          if (userData!.containsKey('gate') && userData!['gate'][gateIndex]['preview'] != null)
            Padding(
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VlcPlayer(
                  controller: _vlcViewController,
                  aspectRatio: 4 / 3,
                  placeholder: Center(child: CircularProgressIndicator()),
                ),
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
                              Vibration.vibrate(duration: 200);
                              CustomToast(context).showToast("Opening Gate", Icons.stop_rounded);
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
                              Vibration.vibrate(duration: 200);
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
                              Vibration.vibrate(duration: 200);
                              CustomToast(context).showToast("Closing Gate", Icons.stop_rounded);
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

          if (userData!.containsKey('lamps'))
            Expanded(
              child: SizedBox(
                height: 250,
                child: GridView.builder(
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
                              color: Colors.grey.withOpacity(0.5),
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
                        )
                      ),
                    ),
                  ),
                ),
              )
            ),
        ],
      ),
    );
  }
}
