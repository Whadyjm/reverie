import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowDialogs {
  static void usedEmail(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'Este email ya se encuentra en uso.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  static void weakPassword(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'La contraseña suministrada es muy débil.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  static void invalidEmail(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(
          'Email inválido.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}