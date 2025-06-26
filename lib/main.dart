import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pillow/provider/button_provider.dart';
import 'package:pillow/provider/calendar_provider.dart';
import 'package:pillow/provider/dream_provider.dart';
import 'package:pillow/screens/login_screen.dart';
import 'package:pillow/screens/onboarding_screen.dart';
import 'package:pillow/screens/secret_pin.dart';
import 'package:pillow/screens/home_screen.dart';
import 'package:pillow/services/noti_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notiService = NotiService();
  await notiService.initNotification();

  await NotiService().scheduleNotification(
    title: '📝🌙✨ Tu diario de sueños te espera',
    body: '¿Recuerdas lo que soñaste anoche?',
    hour: 7,
    minute: 0,
    payload: 'notification_payload',
  );

  await _requestNotificationPermissions();

  final prefs = await SharedPreferences.getInstance();
  final isPinActive = prefs.getBool('isPinActive') ?? false;
  final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;

  final currentUser = FirebaseAuth.instance.currentUser;

  Widget initialScreen;

  if (!onboardingSeen) {
    initialScreen = OnboardingPage();
  } else if (currentUser == null) {
    initialScreen = LoginScreen();
  } else if (isPinActive) {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userPin = userDoc.data()?['pin']?.toString() ?? '';
      final pinCreated = userDoc.data()?['pinCreated'] as bool? ?? false;
      final userHasPin = userPin.isNotEmpty;

      initialScreen = SecretPin(
        userUid: currentUser.uid,
        userHasPin: userHasPin,
        userPin: userPin,
        pinCreated: pinCreated,
      );
    } catch (e) {
      print('Error cargando datos de PIN: $e');
      initialScreen = LoginScreen();
    }
  } else {
    initialScreen = MyHomePage();
  }

  runApp(MyApp(initialScreen: initialScreen));
}


Future<void> _requestNotificationPermissions() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CalendarProvider()),
        ChangeNotifierProvider(create: (context) => ButtonProvider()),
        ChangeNotifierProvider(create: (context) => DreamProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade300),
        ),
        home: initialScreen,
      ),
    );
  }
}
