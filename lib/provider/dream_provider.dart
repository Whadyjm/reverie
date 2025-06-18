import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/dream_model.dart';

class DreamProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  List<Dream> _dreams = [];
  bool _isLoading = true;

  List<Dream> get dreams => _dreams;
  bool get isLoading => _isLoading;

  DreamProvider() {
    fetchDreams();
  }

  Future<void> fetchDreams() async {
    try {
      _isLoading = true;
      notifyListeners();

      var dreamsCollection = firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('dreams');

      var querySnapshot = await dreamsCollection.get();

      _dreams = querySnapshot.docs
          .map((doc) => Dream.fromFirestore({
        'dreamId': doc.id,
        ...doc.data(),
      }))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching dreams: $e');
    }
  }

  List<String> get dreamTitles => _dreams.map((dream) => dream.title).toList();

  Future<void> updateDreamLikeStatus(String dreamId, bool isLiked) async {
    try {
      var dreamsCollection = firestore
          .collection('users')
          .doc(auth.currentUser?.uid)
          .collection('dreams');

      // Update Firestore
      await dreamsCollection.doc(dreamId).update({'isLiked': isLiked});

      // Update local state
      int index = _dreams.indexWhere((dream) => dream.dreamId == dreamId);
      if (index != -1) {
        _dreams[index] = Dream(
          dreamId: _dreams[index].dreamId,
          title: _dreams[index].title,
          classification: _dreams[index].classification,
          analysis: _dreams[index].analysis,
          text: _dreams[index].text,
          isLiked: isLiked,
          rating: _dreams[index].rating,
          timestamp: _dreams[index].timestamp,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating like status: $e');
    }
  }
}