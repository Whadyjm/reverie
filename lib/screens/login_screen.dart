import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pillow/screens/home_screen.dart';

import '../style/text_style.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginScreen(), debugShowCheckedModeBanner: false);
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/pillow_icon.png', height: 200),
            const SizedBox(height: 80),
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
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        // Login Button
                        CustomButton(
                          text: 'Inicia sesión',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MyHomePage();
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        // Register Button
                        CustomButton(
                          text: 'Regístrate',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MyHomePage();
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: const Divider()),
                            const SizedBox(width: 10),
                            const Text(
                              'o',
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
                            child: Image.asset(height: 20, 'assets/google_logo.png'),
                          ),
                          text: 'Inicia con Google',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MyHomePage();
                                },
                              ),
                            );
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
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const CustomTextField({
    required this.hintText,
    required this.icon,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
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
