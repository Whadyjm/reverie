import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CalendarTimeline(),
            DreamByDate(),
            Stack(
              children: [
                TextAudioInput(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
