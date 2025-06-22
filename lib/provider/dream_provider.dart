import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/dream_model.dart';

class DreamProvider extends ChangeNotifier {

  bool _analysisiSelected = false;
  bool get analysisSelected => _analysisiSelected;

  void toggleAnalysisSelected() {
    _analysisiSelected = true;
    notifyListeners();
  }
}