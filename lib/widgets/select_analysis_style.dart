import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reverie/style/text_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/button_provider.dart';
import '../provider/dream_provider.dart';
import 'dialogs/pricing_dialog.dart';

class SelectAnalysisStyle extends StatefulWidget {
  const SelectAnalysisStyle({super.key});

  @override
  State<SelectAnalysisStyle> createState() => _SelectAnalysisStyleState();
}

class _SelectAnalysisStyleState extends State<SelectAnalysisStyle> {
  int? _selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    final analysisSelected = Provider.of<DreamProvider>(context);

    final btnProvider = Provider.of<ButtonProvider>(context);
    final bool isDarkMode = btnProvider.isButtonEnabled;
    final Color textColor = isDarkMode ? Colors.white : Colors.grey.shade900;
    final Color unselectedCardColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;
    final Color selectedCardColor =
        isDarkMode ? Colors.purple.shade400 : Colors.purple.shade100;
    final Color selectedBorderColor =
        isDarkMode ? Colors.purple.shade100 : Colors.purple;

    return AlertDialog(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
      title: Column(
        children: [
          Text(
            '✨ ¿Cómo prefieres explorar tus sueños?',
            style: AppTextStyle.subtitleStyle(textColor),
          ),
          const SizedBox(height: 10),
          Text(
            'Elige el enfoque que más resuene contigo. Puedes cambiarlo luego.',
            style: LexendTextStyle.small2TextStyle(textColor),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                /*setState(() {
                  _selectedCardIndex = 0;
                });*/
                SubscriptionBottomSheet.show(context);
              },
              child: Card(
                elevation: 8,
                shadowColor:
                    isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      _selectedCardIndex == 0
                          ? BorderSide(color: selectedBorderColor, width: 2)
                          : BorderSide.none,
                ),
                color:
                    _selectedCardIndex == 0
                        ? selectedCardColor
                        : unselectedCardColor,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/card4.png',
                        opacity: const AlwaysStoppedAnimation(0.4),
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🧬 Exploración Científica',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Descubre los significados de tus sueños a través de la neurociencia.',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 30,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.indigo,
                        ),
                        child: Center(
                          child: Text(
                            'Pro',
                            style: LexendTextStyle.smallTextStyle(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Psychological Option
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCardIndex = 1;
                });
              },
              child: Card(
                elevation: 8,
                shadowColor:
                    isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      _selectedCardIndex == 1
                          ? BorderSide(color: selectedBorderColor, width: 2)
                          : BorderSide.none,
                ),
                color:
                    _selectedCardIndex == 1
                        ? selectedCardColor
                        : unselectedCardColor,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/card1.png',
                        opacity: const AlwaysStoppedAnimation(0.4),
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '🧠 Exploración Psicológica',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Conecta tu sueño con emociones, partes de ti mismo y símbolos internos.',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mystical Option
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCardIndex = 2;
                });
              },
              child: Card(
                elevation: 8,
                shadowColor:
                    isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      _selectedCardIndex == 2
                          ? BorderSide(color: selectedBorderColor, width: 2)
                          : BorderSide.none,
                ),
                color:
                    _selectedCardIndex == 2
                        ? selectedCardColor
                        : unselectedCardColor,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/card2.png',
                        opacity: const AlwaysStoppedAnimation(0.4),
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/card2.png'),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.4),
                                      BlendMode.darken,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '🔮 Exploración Mística',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Descubre si tu sueño trae un mensaje del alma, una señal del universo o una energía especial.',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hybrid Option
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCardIndex = 3;
                });
              },
              child: Card(
                elevation: 8,
                shadowColor:
                    isDarkMode ? Colors.black54 : Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      _selectedCardIndex == 3
                          ? BorderSide(color: selectedBorderColor, width: 2)
                          : BorderSide.none,
                ),
                color:
                    _selectedCardIndex == 3
                        ? selectedCardColor
                        : unselectedCardColor,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/card3.png',
                        opacity: const AlwaysStoppedAnimation(0.4),
                        fit: BoxFit.fitWidth,
                        width: MediaQuery.of(context).size.width,
                        height: 120,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/card3.png'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.4),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '🌀 Ambas cosas (Híbrido)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Combina los enfoques psicológicos y místicos para una visión más completa.',
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        _selectedCardIndex != null
            ? FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: FadeIn(
                duration: const Duration(microseconds: 1000),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {});
                        final user = FirebaseAuth.instance.currentUser;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user!.uid)
                            .update({
                              'analysisStyle':
                                  _selectedCardIndex == 0
                                      ? 'cientifico'
                                      : _selectedCardIndex == 1
                                      ? 'psicologico'
                                      : _selectedCardIndex == 2
                                      ? 'mistico'
                                      : 'hibrido',
                            });

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                          'analysisStyle',
                          _selectedCardIndex == 0
                              ? 'cientifico'
                              : _selectedCardIndex == 1
                              ? 'psicologico'
                              : _selectedCardIndex == 2
                              ? 'mistico'
                              : 'hibrido',
                        );
                        analysisSelected.toggleAnalysisSelected();
                        analysisSelected.analysisStyle =
                            _selectedCardIndex == 0
                                ? 'cientifico'
                                : _selectedCardIndex == 1
                                ? 'psicologico'
                                : _selectedCardIndex == 2
                                ? 'mistico'
                                : 'hibrido';
                        Navigator.pop(context, _selectedCardIndex);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.purple.shade700.withOpacity(0.2);
                            }
                            return null;
                          },
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade600,
                              Colors.purple.shade600,
                              Colors.deepPurple.shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 88,
                            minHeight: 48,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Confirmar',
                            style: LexendTextStyle.smallTextStyle(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : const SizedBox.shrink(),
      ],
    );
  }
}
