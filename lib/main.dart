import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pillow/provider/button_provider.dart';
import 'package:pillow/provider/calendar_provider.dart';
import 'package:pillow/provider/dream_provider.dart';
import 'package:pillow/screens/login_screen.dart';
import 'package:pillow/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  User? currentUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp(initialScreen: currentUser != null ? MyHomePage() : LoginScreen()));
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