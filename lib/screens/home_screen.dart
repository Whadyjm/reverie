import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/provider/button_provider.dart';
import 'package:pillow/screens/login_screen.dart';
import 'package:pillow/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../style/text_style.dart';
import '../widgets/calendar_timeline.dart';
import '../widgets/dream_by_date.dart';
import '../widgets/text_audio_input.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String apiKey = '';

  @override
  void initState() {
    getAPIKeyFromFirestore();
    initializeButtonState();
    super.initState();
  }

  Future<void> getAPIKeyFromFirestore() async {
    try {
      final doc = await firestore.collection('apiKey').doc('apiKey').get();
      if (doc.exists) {
        setState(() {
          apiKey = doc.data()?['apiKey'] ?? '';
        });
        print(apiKey);
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error fetching API key: $e');
    }
  }

  Future<void> initializeButtonState() async {
    final prefs = await SharedPreferences.getInstance();
    final isButtonEnabled = prefs.getBool('isButtonEnabled') ?? false;
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    if (isButtonEnabled) {
      btnProvider.enableButton();
    } else {
      btnProvider.disableButton();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().userChanges;
    final btnProvider = Provider.of<ButtonProvider>(context);
    return SafeArea(
      child: Scaffold(
        /*appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Pillow',
            style: AppTextStyle.titleStyle(
              btnProvider.isButtonEnabled ? Colors.white : Colors.grey.shade800,
            ),
          ),
          backgroundColor:
              btnProvider.isButtonEnabled ? Colors.transparent : Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                color:
                    btnProvider.isButtonEnabled
                        ? Colors.white
                        : Colors.grey.shade800,
              ),
              onPressed: () {
                settings(context);
              },
            ),
          ],
        ),*/
        body: Container(
          decoration: BoxDecoration(
            gradient:
                btnProvider.isButtonEnabled
                    ? LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        Color(0xFF1A003F),
                        Color(0xFF2E1A5E),
                        Color(0xFF4A3A7C),
                        Color(0xFF6B5A9A),
                      ],
                    )
                    : LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.white,
                        Colors.purple.shade100,
                        Colors.purple.shade200,
                        Colors.indigo.shade400,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pillow',
                        style: AppTextStyle.titleStyle(
                          btnProvider.isButtonEnabled
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width - 250,
                      ), // Add spacing between the Text and CircleAvatar
                      user != null
                          ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  btnProvider.isButtonEnabled
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.shade200,
                              child: StreamBuilder<User?>(
                                stream: user,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && snapshot.data != null) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.network(
                                        snapshot.data!.photoURL ?? '',
                                      ),
                                    );
                                  } else {
                                    return CircleAvatar(
                                      backgroundColor:
                                          btnProvider.isButtonEnabled
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                      /*SizedBox(
                        width: 16,
                      ), // Add spacing between the CircleAvatar and IconButton
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color:
                              btnProvider.isButtonEnabled
                                  ? Colors.white
                                  : Colors.grey.shade800,
                        ),
                        onPressed: () {
                          settings(context);
                        },
                      ),*/
                    ],
                  ),
                ),
              ),
              CalendarTimeline(),
              DreamByDate(),
              TextAudioInput(apiKey: apiKey),
            ],
          ),
        ),
      ),
    );
  }

  void settings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final btnProvider = Provider.of<ButtonProvider>(context);

        return SwitchDarkMode(btnProvider);
      },
    );
  }

  StatefulBuilder SwitchDarkMode(ButtonProvider btnProvider) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        btnProvider.isButtonEnabled
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(
                        width: 8,
                      ), // Add spacing between the icon and text
                      Text(
                        btnProvider.isButtonEnabled
                            ? 'Modo nocturno'
                            : 'Modo diurno',
                        style: RobotoTextStyle.subtitleStyle(
                          Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    activeColor: Colors.purple.shade300,
                    value: btnProvider.isButtonEnabled,
                    onChanged: (value) async {
                      setState(() {
                        if (value) {
                          btnProvider.enableButton();
                        } else {
                          btnProvider.disableButton();
                        }
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isButtonEnabled', value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cerrar sesión',
                    style: RobotoTextStyle.subtitleStyle(Colors.grey.shade700),
                  ),
                  IconButton(
                    onPressed: () {
                      AuthService().signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: Icon(Iconsax.logout_copy),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
