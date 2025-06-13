import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pillow/provider/button_provider.dart';
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
      final doc =
      await firestore.collection('apiKey').doc('apiKey').get();
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
    final btnProvider = Provider.of<ButtonProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Pillow',
          style: AppTextStyle.titleStyle(
            btnProvider.isButtonEnabled ? Colors.white : Colors.grey.shade800,
          ),
        ),
        backgroundColor:
            btnProvider.isButtonEnabled ? Colors.grey.shade600 : Colors.white,
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              btnProvider.isButtonEnabled
                  ? LinearGradient(
                    colors: [
                      Colors.grey.shade600,
                      Colors.grey.shade700,
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                      Colors.black87,
                      Colors.black87,
                      Colors.black87,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
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
          children: [CalendarTimeline(), DreamByDate(), TextAudioInput(apiKey: apiKey,)],
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
          title: Text(
            'Cambiar tema',
            style: RobotoTextStyle.subtitleStyle(Colors.grey.shade800),
          ),
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
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Salir',
                style: RobotoTextStyle.smallTextStyle(Colors.grey.shade800),
              ),
            ),
          ],
        );
      },
    );
  }
}
