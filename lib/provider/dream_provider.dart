import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DreamProvider extends ChangeNotifier {

  bool _analysisiSelected = false;
  bool get analysisSelected => _analysisiSelected;

  String _analysisStyle = '';
  String get analysisStyle => _analysisStyle;

  Future<void> loadAnalysisStyle() async {
    final prefs = await SharedPreferences.getInstance();
    _analysisStyle = prefs.getString('analysisStyle') ?? '';
    notifyListeners();
  }

  void toggleAnalysisSelected() {
    _analysisiSelected = true;
    notifyListeners();
  }
}