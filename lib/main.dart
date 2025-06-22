import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pillow/provider/button_provider.dart';
import 'package:pillow/provider/calendar_provider.dart';
import 'package:pillow/provider/dream_provider.dart';
import 'package:pillow/screens/login_screen.dart';
import 'package:pillow/screens/secret_pin.dart';
import 'package:pillow/services/noti_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notiService = NotiService();
  await notiService.initNotification();

  await NotiService().scheduleNotification(
    title: '📝🌙✨ Tu diario de sueños te espera',
    body: '¿Recuerdas lo que soñaste anoche?',
    hour: 7,
    minute: 0,
    payload: 'notification_payload',
  );

  // Optional: Request notification permissions (required for Android 13+)
  await _requestNotificationPermissions();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final user = FirebaseAuth.instance.currentUser;

    // Si no hay usuario autenticado, vamos directamente a LoginScreen
    if (user == null) {
      return runApp(MyApp(initialScreen: LoginScreen()));
    }

    // Obtener datos del usuario de Firestore
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    // Manejar casos donde el documento no existe o campos son nulos
    final userPin = userDoc.data()?['pin']?.toString() ?? '';
    final pinCreated = userDoc.data()?['pinCreated'] as bool? ?? false;
    final userHasPin = userPin.isNotEmpty;

    print('----------$userPin-----------');

    runApp(
      MyApp(
        initialScreen: SecretPin(
          userUid: user.uid,
          userHasPin: userHasPin,
          userPin: userPin,
          pinCreated: pinCreated,
        ),
      ),
    );
  } catch (e) {
    // Manejo de errores - podrías mostrar una pantalla de error o ir al login
    print('Error inicializando la app: $e');
    runApp(MyApp(initialScreen: LoginScreen()));
  }
}

Future<void> _requestNotificationPermissions() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
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
