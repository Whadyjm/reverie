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
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;
  bool isLoadingGoogle = false;

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);
    await AuthProcess.login(
      context,
      emailController,
      passwordController,
      setState,
      isLoading,
    );
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoadingGoogle = true);
    await AuthProcess.googleSignIn(context, setState, isLoading);
  }

  @override
  Widget build(BuildContext context) {
    final mediaHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          height: mediaHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: Gradients.loginBackground,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/reverie_icon.png', height: 200),
                  const SizedBox(height: 30),
                  _buildLoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Center(
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

                CustomTextField(
                  hintText: 'Correo electrónico',
                  icon: Icons.person,
                  controller: emailController, obscureText: false,
                ),
                const SizedBox(height: 15),

                CustomTextField(
                  hintText: 'Contraseña',
                  icon: Icons.lock,
                  controller: passwordController,
                  obscureText: hidePassword,
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => hidePassword = !hidePassword),
                    icon: Icon(
                      hidePassword ? Iconsax.eye : Iconsax.eye_slash,
                      color: Colors.white70,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ForgotPasswordModalSheet.show(
                        context,
                        isLoading,
                        emailController,
                        setState,
                      );
                    },
                    child: Text(
                      'Recuperar contraseña',
                      style: RobotoTextStyle.small2TextStyle(Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                isLoading
                    ? const SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                )
                    : CustomButton(
                  text: 'Iniciar sesión',
                  onPressed: _handleLogin,
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
                    style: RobotoTextStyle.subtitleStyle(Colors.white),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    SizedBox(width: 10),
                    Text('ó', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 10),

                CustomButton(
                  text: 'Continuar con Google',
                  image: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/google_logo.png',
                      height: 20,
                    ),
                  ),
                  onPressed: _handleGoogleSignIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
