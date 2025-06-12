import 'package:flutter/cupertino.dart';

class ButtonProvider with ChangeNotifier {
  bool _isButtonEnabled = false;

  bool get isButtonEnabled => _isButtonEnabled;

  void toggleButton() {
    _isButtonEnabled = !_isButtonEnabled;
    notifyListeners();
  }

  void enableButton() {
    _isButtonEnabled = true;
    notifyListeners();
  }

  void disableButton() {
    _isButtonEnabled = false;
    notifyListeners();
  }
}