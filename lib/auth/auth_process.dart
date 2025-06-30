import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/secret_pin.dart';
import '../services/auth_service.dart';
import '../widgets/show_dialogs.dart';

class AuthProcess {
  static void register(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    String? selectedGender,
    setState,
    isLoading,
  ) async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Por favor, complete todos los campos',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              backgroundColor: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      );
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      var doc = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      await doc.set({
        'analysisStyle': '',
        'name': nameController.text.trim(),
        'photoUrl': '',
        'email': emailController.text.trim(),
        'userId': user.uid,
        'userSince': FieldValue.serverTimestamp(),
        'pinCreated': true,
        'selectedGender': selectedGender ?? ''
      });

      String userPin = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()?['pin'] ?? '');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  userPin.isNotEmpty
                      ? MyHomePage()
                      : SecretPin(userUid: user.uid),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ShowDialogs.usedEmail(context);
      } else if (e.code == 'weak-password') {
        ShowDialogs.weakPassword(context);
      } else if (e.code == 'invalid-email') {
        ShowDialogs.invalidEmail(context);
      } else {
        print("Error: ${e.code}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  static Future<void> login(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    setState,
    isLoading,
  ) async {
    {
      if (emailController.text.trim().isEmpty ||
          passwordController.text
              .trim()
              .isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Por favor, complete todos los campos',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor:
            Colors.grey.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
      try {
        setState(() {
          isLoading = true;
        });

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = FirebaseAuth.instance.currentUser;
        String? userUid = user?.uid;

        String userPin =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid).get().then((value) => value.data()?['pin']);

        bool pinCreated = await FirebaseFirestore.instance
            .collection('users')
            .doc(userUid)
            .get()
            .then((value) => value.data()?['pinCreated']);

        print('----------$userPin-----------');

        bool userHasPin = userPin.isEmpty ? false : true;

        if (userCredential.user != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
              userPin.isNotEmpty
                  ? SecretPin(
                userUid: userUid!,
                userHasPin: userHasPin,
                userPin: userPin,
                pinCreated: pinCreated,
              )
                  : MyHomePage(),
            ),
                (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'El correo electrónico y/o contraseña no es válido.';
            break;
          case 'user-not-found':
            errorMessage = 'No se encontró un usuario con este correo.';
            break;
          case 'wrong-password':
            errorMessage = 'La contraseña es incorrecta.';
            break;
          case 'network-request-failed':
            errorMessage = 'Error de red. Verifica tu conexión.';
            break;
          default:
            errorMessage = 'El correo electrónico y/o contraseña no es válido.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  static Future<void> googleSignIn (
    BuildContext context,
    setState,
    isLoading,
  ) async {
    {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.purple.shade300,
                  ),
                ),
              ),
            ),
          ),
        );

        final userCred = await AuthService().signInWithGoogle();

        if (userCred != null) {
          final user = userCred.user!;
          final doc = FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid);
          final docSnapshot = await doc.get();

          if (!docSnapshot.exists) {
            await doc.set({
              'name': user.displayName,
              'photoUrl': user.photoURL,
              'email': user.email,
              'userId': user.uid,
              'userSince': FieldValue.serverTimestamp(),
              'pinCreated': true,
              'pin': '',
              'selectedGender': '',
            });
          }

          final userData = await doc.get();
          final userPin = userData.data()?['pin'] ?? '';
          final pinCreated = userData.data()?['pinCreated'] ?? false;
          bool userHasPin = userPin.isEmpty ? false : true;

          Navigator.of(context).pop();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SecretPin(
                userUid: user.uid,
                userHasPin: userHasPin,
                userPin: userPin,
                pinCreated: pinCreated,
              ),
            ),
                (route) => false,
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        print("Error during Google Sign-In: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error, intente de nuevo')));
      }
    }
  }
}
