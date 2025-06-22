import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/screens/login_screen.dart';
import 'package:pillow/services/noti_service.dart';
import 'package:pillow/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/button_provider.dart';
import '../provider/calendar_provider.dart';
import '../provider/dream_provider.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';
import '../style/text_style.dart';
import '../widgets/calendar_timeline.dart';
import '../widgets/dream_by_date.dart';
import '../widgets/select_analysis_style.dart';
import '../widgets/text_audio_input.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String apiKey = '';
  TextEditingController _dreamController = TextEditingController();
  bool isLoading = false;
  String analysisStyle = '';

  @override
  void initState() {
    super.initState();
    getAPIKeyFromFirestore();
    initializeButtonState();
    getAnalysisStyle();
    print('-----------------------$analysisStyle-------------------------');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _dreamController.dispose();
    super.dispose();
  }

  Future<void> getAnalysisStyle() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchedAnalysisStyle =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid).get().then((value) => value.data()?['analysisStyle'] ?? '');
        setState(() {
          analysisStyle = fetchedAnalysisStyle;
        });
      }
      print('-----------------$analysisStyle-----------------');
    } catch (e) {
      print('Error fetching analysis style: $e');
    }
  }

  Future<void> getAPIKeyFromFirestore() async {
    try {
      final doc = await firestore.collection('apiKey').doc('apiKey').get();
      if (doc.exists) {
        setState(() {
          apiKey = doc.data()?['apiKey'] ?? '';
        });
        print('-----------------------------$apiKey-----------------------------------');
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
    final analysisSelected = Provider.of<DreamProvider>(context).analysisSelected;
    final _selectedDate = Provider.of<CalendarProvider>(context).selectedDate;

    return WillPopScope(
      onWillPop: () async {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
          return false; // Prevent default back navigation
        }
        return true; // Allow default back navigation
      },
      child: SafeArea(
        child: Scaffold(
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
                          Color(0xFF8C53D6),
                          Color(0xFFAD75F4),
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
                        SizedBox(width: MediaQuery.sizeOf(context).width - 250),
                        user != null
                            ? GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                settings(context);
                              },
                              child: Padding(
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
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          child: Image.network(
                                            snapshot.data!.photoURL ??
                                                'https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg',
                                          ),
                                        );
                                      } else {
                                        return CircleAvatar(
                                          backgroundColor:
                                              btnProvider.isButtonEnabled
                                                  ? Colors.white.withOpacity(
                                                    0.2,
                                                  )
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
                              ),
                            )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
                CalendarTimeline(),
                DreamByDate(),
                //TextAudioInput(apiKey: apiKey),
              ],
            ),
          ),
          floatingActionButton: Pulse(
            duration: Duration(milliseconds: 800),
            child: FloatingActionButton(
              onPressed: () {
                if (analysisStyle.isEmpty && analysisSelected == false) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SelectAnalysisStyle();
                    },
                  );
                } else if (analysisStyle.isNotEmpty || analysisSelected == true){
                showModalBottomSheet(context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  backgroundColor:
                  btnProvider.isButtonEnabled
                      ? Colors.grey.shade900
                      : Colors.white,
                  builder: (BuildContext context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: 16.0,
                        bottom:
                        MediaQuery.of(context)
                            .viewInsets
                            .bottom, // Ajusta el espacio según el teclado
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¿Qué soñaste hoy?',
                              style: AppTextStyle.subtitleStyle(
                                btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                fontFamily: 'roboto',
                                color:
                                btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              controller: _dreamController,
                              decoration: InputDecoration(
                                hintText: 'Escribe tu sueño...',
                                hintStyle: TextStyle(
                                  color:
                                  btnProvider.isButtonEnabled
                                      ? Colors.white70
                                      : Colors.grey.shade500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 70,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (_dreamController.text.trim().isEmpty) {
                                    return;
                                  }
                                  try {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    final title = await GeminiService()
                                        .generateTitle(
                                      _dreamController.text,
                                      apiKey,
                                    );
                                    FirebaseService().saveDream(
                                      context,
                                      _dreamController,
                                      _selectedDate,
                                      title,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error, intente de nuevo',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    _dreamController.clear();
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.purple.shade400,
                                        Colors.purple.shade600,
                                        Colors.indigo.shade400,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child:
                                    isLoading
                                        ? SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 4,
                                        valueColor:
                                        AlwaysStoppedAnimation<
                                            Color
                                        >(Colors.white),
                                      ),
                                    )
                                        : Text(
                                      'Guardar',
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                },
                );}
              },
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.purple.shade600,
                      Colors.indigo.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
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
                      SizedBox(width: 8),
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
