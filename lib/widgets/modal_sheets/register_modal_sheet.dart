import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reverie/provider/button_provider.dart';
import 'package:reverie/widgets/threedotsloading.dart';
import '../../auth/auth_process.dart';
import '../../style/text_style.dart';
import '../custom_button.dart';
import '../custom_textfield.dart';

class RegisterModalSheet {
  void show(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    bool hidePassword,
    Function setState,
    bool isLoading,
  ) {
    String? selectedGender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withAlpha(250),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            final btnProvider = Provider.of<ButtonProvider>(
              context,
              listen: false,
            );
            Future<void> _handleRegister() async {
              final btnProvider = Provider.of<ButtonProvider>(
                context,
                listen: false,
              );
              try {
                btnProvider.setLoading(true);
                await AuthProcess.register(
                  context,
                  nameController,
                  emailController,
                  passwordController,
                  selectedGender,
                  setState,
                  isLoading,
                );
              } catch (e) {
              } finally {
                btnProvider.setLoading(false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Registro',
                      style: LexendTextStyle.titleStyle(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hintText: 'Nombre y apellido',
                    icon: Icons.person,
                    obscureText: false,
                    controller: nameController,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    hintText: 'Correo electrónico',
                    icon: Icons.email,
                    obscureText: false,
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
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
                        hidePassword ? Iconsax.eye : Iconsax.eye_slash,
                        color: Colors.white70,
                      ),
                    ),
                    obscureText: hidePassword,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 20),
                  // Gender selection row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGenderCard(
                        context: context,
                        isSelected: selectedGender == 'male',
                        icon: Icons.male,
                        iconColor: Colors.blue,
                        onTap: () => setState(() => selectedGender = 'male'),
                      ),
                      _buildGenderCard(
                        context: context,
                        isSelected: selectedGender == 'female',
                        icon: Icons.female,
                        iconColor: Colors.pinkAccent,
                        onTap: () => setState(() => selectedGender = 'female'),
                      ),
                      _buildGenderCard(
                        context: context,
                        isSelected: selectedGender == 'other',
                        icon: Icons.transgender,
                        iconColor: Colors.purple,
                        onTap: () => setState(() => selectedGender = 'other'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  btnProvider.isLoading
                      ? SizedBox(
                        width: 40,
                        height: 25,
                        child: ThreeDotsLoading(color: Colors.white),
                      )
                      : CustomButton(
                        text: 'Registrar',
                        onPressed: _handleRegister,
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGenderCard({
    required BuildContext context,
    required bool isSelected,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade600 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 30, color: iconColor)],
        ),
      ),
    );
  }
}
