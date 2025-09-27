import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reverie/model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (doc.exists) {
        _user = UserModel.fromJson(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al cargar usuario: $e');
    }
  }

  Stream<UserModel?> listenUser(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        final user = UserModel.fromJson(doc.data()!);
        _user = user;
        notifyListeners();
        return user;
      }
      return null;
    });
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
