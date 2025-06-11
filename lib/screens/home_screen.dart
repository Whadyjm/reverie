import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Pillow', style: TextStyle(color: Colors.grey.shade800, fontFamily: 'instrumental', fontWeight: FontWeight.w600, fontSize: 40)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white, Colors.white, Colors.white, Colors.purple.shade100, Colors.purple.shade200, Colors.indigo.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
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
