import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pillow/provider/calendar_provider.dart';
import 'package:pillow/provider/dream_provider.dart';
import 'package:pillow/screens/home_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CalendarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple.shade300),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
