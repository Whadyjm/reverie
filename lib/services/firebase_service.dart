import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {

  void saveDream(context, controller, selectedDate, title) async {

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('dreams').add({
        'title': title,
        'text': controller.text.trim(),
        'timestamp': DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al enviar el sueño.',
          ),
        ),
      );
    } finally {
      controller.clear();
      FocusScope.of(context).unfocus();
    }
  }
}