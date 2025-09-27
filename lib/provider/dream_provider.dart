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

  set analysisStyle(String style) {
    _analysisStyle = style;
    notifyListeners();
  }

  void toggleAnalysisSelected() {
    _analysisiSelected = true;
    notifyListeners();
  }
}
