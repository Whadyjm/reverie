import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reverie/services/emotion_service.dart';

class FirebaseService {
  Future<int> getDreamCountByUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final dreamsSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('dreams')
                .get();
        return dreamsSnapshot.docs.length;
      }
    } catch (e) {
      print('Error getting dream count: $e');
    }
    return 0;
  }

  Future<String> getUserSelectedGender() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchUserSelectedGender = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['selectedGender'] ?? '');
        return fetchUserSelectedGender;
      }
    } catch (e) {}
    return '';
  }

  Future<String> getUserSuscription() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchUserSuscription = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['suscription'] ?? '');
        return fetchUserSuscription;
      }
    } catch (e) {}
    return '';
  }

  Future<String> getUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchUserName = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['name'] ?? '');
        return fetchUserName;
      }
    } catch (e) {}
    return '';
  }

  Future<String> getAnalysisStyle() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final fetchedAnalysisStyle = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((value) => value.data()?['analysisStyle'] ?? '');
        return fetchedAnalysisStyle;
      }
    } catch (e) {
      print('Error fetching analysis style: $e');
    }
    return 'psicologico';
  }

  Future<String> getAPIKeyFromFirestore() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('apiKey')
              .doc('apiKey')
              .get();
      if (doc.exists) {
        return doc.data()?['apiKey'] ?? '';
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error fetching API key: $e');
    }
    return '';
  }

  Future<String> generateMonthlyEmotion() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final doc =
          await FirebaseFirestore.instance
              .collection('apiKey')
              .doc('apiKey')
              .get();

      final result = await EmotionService().analyzeUserEmotions(
        userId!,
        doc.data()?['apiKey'] ?? '',
      );

      var monthlyEmotionCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('monthlyEmotions');

      var documentRef = await monthlyEmotionCollection.add({
        'emotion': result,
        'month': Timestamp.now().toDate().month,
      });
    } catch (e) {
    } finally {}
    return '';
  }

  Stream<int> fetchDreamCountByDate(DateTime date) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('dreams')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day),
        )
        .where(
          'timestamp',
          isLessThan: DateTime(date.year, date.month, date.day + 1),
        )
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }

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
