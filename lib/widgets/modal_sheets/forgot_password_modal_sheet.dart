import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../style/text_style.dart';
import '../custom_button.dart';
import '../custom_textfield.dart';

class ForgotPasswordModalSheet {
  static void show(context, isLoading, emailController, setState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withAlpha(250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Recuperar contraseña',
                  style: RobotoTextStyle.titleStyle(Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                autofocus: true,
                hintText: 'Correo electrónico',
                icon: Icons.email,
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.purple.shade300,
                      ),
                    ),
                  )
                  : CustomButton(
                    text: 'Enviar',
                    onPressed: () async {
                      final email = emailController.text.trim();
                      if (email.isNotEmpty) {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: email,
                          );
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.black.withAlpha(250),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Text('Correo de recuperación enviado.'),
                            ),
                          );
                        } catch (e) {}
                      }
                    },
                  ),
            ],
          ),
        );
      },
    );
  }
}
