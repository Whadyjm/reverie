import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  void saveDream(
    context,
    controller,
    selectedDate,
    title,
    analysis,
    tag,
    emotions,
    analysisStyle,
  ) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      var dreamsCollection = firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('dreams');

      final dreamId = FirebaseFirestore.instance.collection('dreams').doc().id;

      var documentRef = await dreamsCollection.add({
        'dreamId': dreamId,
        'title': title,
        'classification': tag,
        'analysis': analysis,
        'emotions': emotions,
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

      await documentRef.update({'dreamId': documentRef.id});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar el sueño.')));
    } finally {
      controller.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void sendFeedback(String feedback) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await firestore.collection('feedback').add({
        'userId': auth.currentUser?.uid,
        'email': auth.currentUser?.email,
        'feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al enviar el feedback: $e');
    }
  }
}
