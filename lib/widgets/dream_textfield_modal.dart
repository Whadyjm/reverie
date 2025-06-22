import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/button_provider.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';
import '../style/text_style.dart';

class DreamTextfieldModal extends StatefulWidget {
  const DreamTextfieldModal({super.key});

  @override
  State<DreamTextfieldModal> createState() => _DreamTextfieldModalState();
}

class _DreamTextfieldModalState extends State<DreamTextfieldModal> {
  @override
  Widget build(BuildContext context) {
    return Placeholder();/*showModalBottomSheet(context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        backgroundColor:
                        btnProvider.isButtonEnabled
                            ? Colors.grey.shade900
                            : Colors.white,
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom:
                              MediaQuery.of(context)
                                  .viewInsets
                                  .bottom, // Ajusta el espacio según el teclado
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '¿Qué soñaste hoy?',
                                    style: AppTextStyle.subtitleStyle(
                                      btnProvider.isButtonEnabled
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    textCapitalization: TextCapitalization.sentences,
                                    style: TextStyle(
                                      fontFamily: 'roboto',
                                      color:
                                      btnProvider.isButtonEnabled
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    controller: _dreamController,
                                    decoration: InputDecoration(
                                      hintText: 'Escribe tu sueño...',
                                      hintStyle: TextStyle(
                                        color:
                                        btnProvider.isButtonEnabled
                                            ? Colors.white70
                                            : Colors.grey.shade500,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    maxLines: 5,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 70,
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        if (_dreamController.text.trim().isEmpty) {
                                          return;
                                        }
                                        try {
                                          setState(() {
                                            isLoading = true;
                                          });

                                          final title = await GeminiService()
                                              .generateTitle(
                                            _dreamController.text,
                                            apiKey,
                                          );
                                          FirebaseService().saveDream(
                                            context,
                                            _dreamController,
                                            _selectedDate,
                                            title,
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error, intente de nuevo',
                                              ),
                                            ),
                                          );
                                        } finally {
                                          setState(() {
                                            isLoading = false;
                                          });
                                          _dreamController.clear();
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.purple.shade400,
                                              Colors.purple.shade600,
                                              Colors.indigo.shade400,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child:
                                          isLoading
                                              ? SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 4,
                                              valueColor:
                                              AlwaysStoppedAnimation<
                                                  Color
                                              >(Colors.white),
                                            ),
                                          )
                                              : Text(
                                            'Guardar',
                                            style: TextStyle(
                                              fontFamily: 'roboto',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
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
                    );*/

  }
}
