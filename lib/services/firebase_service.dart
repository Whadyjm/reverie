import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  void saveDream(context, controller, selectedDate, title, analysisStyle) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      var dreamsCollection = firestore.collection('users')
          .doc(auth.currentUser?.uid)
          .collection('dreams');

      final dreamId = FirebaseFirestore.instance.collection('dreams').doc().id;
      // Agregar el documento y obtener la referencia
      var documentRef = await dreamsCollection.add({
        'dreamId': dreamId,
        'title': title.split('\n\n')[0],
        'classification': title.split('\n\n')[1],
        'analysis': title.split('\n\n').sublist(2).join('\n\n'),
        'analysisStyle': analysisStyle,
        'text': controller.text.trim(),
        'isLiked': false,
        'rating': 0,
        'timestamp': DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ),
      });

      // Actualizar el documento con el dreamId
      await documentRef.update({'dreamId': documentRef.id});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el sueño.')),
      );
    } finally {
      controller.clear();
      FocusScope.of(context).unfocus();
    }
  }
}
