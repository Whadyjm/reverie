import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reverie/style/text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectGenderDialog extends StatefulWidget {
  SelectGenderDialog({
    super.key,
    required this.selectedGender,
    required this.dontShowAgain,
  });

  late String selectedGender;
  late bool dontShowAgain;

  @override
  State<SelectGenderDialog> createState() => _SelectGenderDialogState();
}

class _SelectGenderDialogState extends State<SelectGenderDialog> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Column(
            children: [
              Text(
                'Selecciona tu género',
                style: LexendTextStyle.subtitleStyle(Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Esto nos permitirá personalizar tu experiencia',
                style: LexendTextStyle.small2TextStyle(Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGenderCard(
                    context: context,
                    isSelected: widget.selectedGender == 'male',
                    icon: Icons.male,
                    iconColor: Colors.blue,
                    onTap: () => setState(() => widget.selectedGender = 'male'),
                  ),
                  _buildGenderCard(
                    context: context,
                    isSelected: widget.selectedGender == 'female',
                    icon: Icons.female,
                    iconColor: Colors.pinkAccent,
                    onTap:
                        () => setState(() => widget.selectedGender = 'female'),
                  ),
                  _buildGenderCard(
                    context: context,
                    isSelected: widget.selectedGender == 'other',
                    icon: Icons.transgender,
                    iconColor: Colors.purple,
                    onTap:
                        () => setState(() => widget.selectedGender = 'other'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: widget.dontShowAgain,
                    onChanged: (value) {
                      setState(() {
                        widget.dontShowAgain = value ?? false;
                      });
                    },
                    activeColor: Colors.purple,
                    checkColor: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "No volver a mostrar",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Prefiero no hacerlo',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final userUid = FirebaseAuth.instance.currentUser!.uid;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool(
                      'dontShowGenderDialog',
                      widget.dontShowAgain,
                    );
                    await firestore.collection('users').doc(userUid).update({
                      'selectedGender': widget.selectedGender,
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Continuar',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
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
        width: 70,
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
