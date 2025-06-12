import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillow/services/firebase_service.dart';
import 'package:pillow/widgets/audio_button.dart';
import 'package:pillow/widgets/dream_textfield.dart';
import 'package:pillow/widgets/save_dream_icon.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';

class TextAudioInput extends StatefulWidget {
  const TextAudioInput({super.key});

  @override
  State<TextAudioInput> createState() => _TextAudioInputState();
}

class _TextAudioInputState extends State<TextAudioInput> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _dreamController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final _selectedDate = Provider.of<CalendarProvider>(context).selectedDate;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF000000).withAlpha(10),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                DreamTextfield(dreamController: _dreamController),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    FirebaseService().saveDream(context, _dreamController, _selectedDate);
                  },
                  icon: SaveDreamIcon()
                ),
              ],
            ),
          ),
        ),
        AudioButton()
      ],
    );
  }
}
