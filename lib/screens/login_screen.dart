import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/screens/home_screen.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../style/text_style.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF5F0AFF),
                  Color(0xFF8C53D6),
                  Color(0xFFAD75F4),
                  Color(0xFFCB97FB),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/pillow_icon.png', height: 200),
                  const SizedBox(height: 30),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Iniciar Sesión',
                                style: RobotoTextStyle.titleStyle(Colors.white),
                              ),
                              const SizedBox(height: 20),
                              // Email Field
                              CustomTextField(
                                hintText: 'Correo electrónico',
                                icon: Icons.person,
                                obscureText: false,
                              ),
                              const SizedBox(height: 15),
                              // Password Field
                              CustomTextField(
                                hintText: 'Contraseña',
                                icon: Icons.lock,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePassword = !hidePassword;
                                    });
                                  },
                                  icon: Icon(
                                    hidePassword
                                        ? Iconsax.eye
                                        : Iconsax.eye_slash,
                                    color: Colors.white70,
                                  ),
                                ),
                                obscureText: hidePassword,
                              ),
                              const SizedBox(height: 20),
                              // Login Button
                              CustomButton(
                                text: 'Inicia sesión',
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyHomePage(),
                                    ),
                                    (route) =>
                                        false, // Clear the navigation stack
                                  );
                                },
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyHomePage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  'Regístrate',
                                  style: RobotoTextStyle.subtitleStyle(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(child: const Divider()),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'ó',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: const Divider()),
                                ],
                              ),
                              const SizedBox(height: 10),
                              CustomButton(
                                image: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Image.asset(
                                    height: 20,
                                    'assets/google_logo.png',
                                  ),
                                ),
                                text: 'Continuar con Google',
                                onPressed: () async {
                                  setState(() {
                                    isLoading =
                                        true; // Activar indicador de carga
                                  });
                                  await googleSignIn(context);
                                  setState(() {
                                    isLoading =
                                        false; // Desactivar indicador de carga
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: true, // Permitir cancelar al presionar fuera
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
        String userId = Uuid().v4();

        if (!docSnapshot.exists) {
          await doc.set({
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'email': user.email,
            'userId': userId,
            'userSince': FieldValue.serverTimestamp(),
          });
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error, intente de nuevo')));
    } finally {
      Navigator.of(context).pop(); // Cerrar el diálogo
    }
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  Widget? suffixIcon;

  CustomTextField({
    required this.hintText,
    required this.icon,
    this.suffixIcon,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  void Function()? onPressed;
  Widget? image;
  CustomButton({super.key, required this.text, this.onPressed, this.image});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: image,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      label: Text(text),
    );
  }
}
