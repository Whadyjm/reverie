import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillow/services/firebase_service.dart';
import 'package:pillow/style/text_style.dart';
import 'package:pillow/widgets/audio_button.dart';
import 'package:pillow/widgets/dream_textfield.dart';
import 'package:pillow/widgets/save_dream_icon.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
import '../services/gemini_service.dart';

class TextAudioInput extends StatefulWidget {
  const TextAudioInput({super.key, required this.apiKey});

  final String apiKey;
  @override
  State<TextAudioInput> createState() => _TextAudioInputState();
}

class _TextAudioInputState extends State<TextAudioInput> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _dreamController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final _selectedDate = Provider.of<CalendarProvider>(context).selectedDate;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            width: MediaQuery.of(context).size.width - 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    if (_dreamController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.grey.shade700,
                          content: Text(
                            'El campo de texto está vacío',
                            style: RobotoTextStyle.smallTextStyle(Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return;
                    }
                    try {
                      setState(() {
                        isLoading = true;
                      });

                      final title = await GeminiService().generateTitle(
                        _dreamController.text, widget.apiKey
                      );
                      FirebaseService().saveDream(
                        context,
                        _dreamController,
                        _selectedDate,
                        title
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error, intente de nuevo')),
                      );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                      _dreamController.clear();
                    }
                  },
                  icon: isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade300),
                    ),
                  )
                      : SaveDreamIcon(),
                ),
              ],
            ),
          ),
        ),
        AudioButton(),
      ],
    );
  }
}
