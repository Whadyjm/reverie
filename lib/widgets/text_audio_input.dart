import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    controller: _dreamController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        letterSpacing: 1.2,
                        fontFamily: 'instrumental',
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                      hintText: '¿Qué soñaste hoy?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    try {
                      await firestore.collection('dreams').add({
                        'text': _dreamController.text.trim(),
                        'timestamp': DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                        ),
                      });
                      _dreamController.clear();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error al enviar el sueño.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.indigo.shade100,
                          Colors.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0xFF000000).withAlpha(10),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [
                    Colors.purple.shade300,
                    Colors.indigo.shade100,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: const Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
