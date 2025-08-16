import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonProvider with ChangeNotifier {
  bool _isButtonEnabled = false;
  bool _isTextBlurred = false;
  bool _isPinActive = true;
  bool _isLoading = false;

  bool get isButtonEnabled => _isButtonEnabled;
  bool get isTextBlurred => _isTextBlurred;
  bool get isPinActive => _isPinActive;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void togglePin() {
    _isPinActive = !_isPinActive;
    notifyListeners();
  }

  void enablePin() {
    _isPinActive = true;
    notifyListeners();
  }

  void disablePin() {
    _isPinActive = false;
    notifyListeners();
  }

  Future<void> loadPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPinActive = prefs.getBool('isPinActive') ?? false;
    notifyListeners();
  }

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

  void toggleTextBlur() {
    _isTextBlurred = !_isTextBlurred;
    notifyListeners();
  }

  void enableTextBlur() {
    _isTextBlurred = true;
    notifyListeners();
  }

  void disableTextBlur() {
    _isTextBlurred = false;
    notifyListeners();
  }
}
