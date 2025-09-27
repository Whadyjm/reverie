import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reverie/model/user_model.dart';
import '../screens/home_screen.dart';
import '../screens/secret_pin.dart';
import '../services/auth_service.dart';
import '../widgets/show_dialogs.dart';

class AuthProcess {
  static Future<void> register(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    String? selectedGender,
    Function(void Function()) setState,
    bool isLoading,
  ) async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
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

      //Crear usuario en FirebaseAuth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null)
        throw Exception("Usuario no encontrado tras el registro");

      //Construir UserModel
      final newUser = UserModel(
        userId: user.uid,
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        photoUrl: '',
        userSince: Timestamp.now(),
        suscription: 'free',
        selectedGender: selectedGender ?? '',
        analysisStyle: '',
        pin: '',
        pinCreatedAt: Timestamp.now(),
        pinCreated: false,
      );

      //Guardar en Firestore usando toJson
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser.toJson());

      //Revisar si tiene PIN
      String userPin = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) => value.data()?['pin'] ?? '');

      //Redirigir según el pin
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
        debugPrint("Error Auth: ${e.code}");
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
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
    Function(void Function()) setState,
    bool isLoading,
  ) async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor, complete todos los campos',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey.shade900,
          behavior: SnackBarBehavior.floating,
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

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) throw Exception("Usuario no encontrado");

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!doc.exists) throw Exception("El usuario no existe en Firestore");

      final loggedUser = UserModel.fromJson(doc.data()!);

      final userPin = loggedUser.pin;
      final pinCreated = loggedUser.pinCreated;
      final userHasPin = userPin.isNotEmpty;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  userHasPin
                      ? SecretPin(
                        userUid: loggedUser.userId,
                        userHasPin: userHasPin,
                        userPin: userPin,
                        pinCreated: pinCreated,
                      )
                      : MyHomePage(),
        ),
        (route) => false,
      );
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
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey.shade900,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error inesperado en login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al iniciar sesión, intente de nuevo'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  static Future<void> googleSignIn(
    BuildContext context,
    Function(void Function()) setState,
    bool isLoading,
  ) async {
    try {
      // 🔹 Loading Dialog
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

      //Inicio de sesion con Google
      final userCred = await AuthService().signInWithGoogle();

      if (userCred != null) {
        final user = userCred.user!;
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await docRef.get();

        //Si no existe el documento, se crea un nuevo UserModel
        if (!docSnapshot.exists) {
          final newUser = UserModel(
            userId: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
            photoUrl: user.photoURL ?? '',
            userSince: Timestamp.now(),
            suscription: 'free',
            selectedGender: '',
            analysisStyle: '',
            pin: '',
            pinCreatedAt: Timestamp.now(),
            pinCreated: false,
          );

          await docRef.set(newUser.toJson());
        }

        //Obtener datos del usuario
        final userData = await docRef.get();
        final data = userData.data() ?? {};

        final userPin = data['pin'] ?? '';
        final pinCreated = data['pinCreated'] ?? false;
        final userHasPin = userPin.isNotEmpty;

        //Cerrar el dialogo de carga
        Navigator.of(context).pop();

        //Redirigir
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
      debugPrint("Error during Google Sign-In: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error, intente de nuevo')));
    }
  }
}
