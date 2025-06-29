import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/widgets/modal_sheets/forgot_password_modal_sheet.dart';
import 'package:pillow/widgets/modal_sheets/register_modal_sheet.dart';
import '../auth/auth_process.dart';
import '../style/gradients.dart';
import '../style/text_style.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hidePassword = true;
  bool isLoading = false;
  bool isLoadingGoogle = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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
                colors: Gradients.loginBackground,
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
                                'Inicia Sesión',
                                style: RobotoTextStyle.titleStyle(Colors.white),
                              ),
                              const SizedBox(height: 20),
                              // Email Field
                              CustomTextField(
                                hintText: 'Correo electrónico',
                                icon: Icons.person,
                                obscureText: false,
                                controller: emailController,
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
                                controller: passwordController,
                              ),
                              TextButton(
                                onPressed: () async {
                                  ForgotPasswordModalSheet.show(
                                    context,
                                    isLoading,
                                    emailController,
                                    setState,
                                  );
                                },
                                child: Text(
                                  'Recuperar contraseña',
                                  style: RobotoTextStyle.small2TextStyle(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              isLoading
                                  ? SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.purple.shade300,
                                      ),
                                    ),
                                  )
                                  : CustomButton(
                                    text: 'Iniciar sesión',
                                    onPressed: () async {
                                      setState(() {
                                        AuthProcess.login(
                                          context,
                                          emailController,
                                          passwordController,
                                          setState,
                                          isLoading,
                                        );
                                      });
                                    },
                                  ),
                              TextButton(
                                onPressed: () {
                                  RegisterModalSheet().show(
                                    context,
                                    nameController,
                                    emailController,
                                    passwordController,
                                    hidePassword,
                                    setState,
                                    isLoading,
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
                                    isLoadingGoogle =
                                        true; // Activar indicador de carga
                                  });
                                  AuthProcess.googleSignIn(
                                    context,
                                    setState,
                                    isLoading,
                                  );
                                  setState(() {
                                    isLoadingGoogle =
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
}
