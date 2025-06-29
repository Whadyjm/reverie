import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/button_provider.dart';
import '../provider/calendar_provider.dart';
import '../style/text_style.dart';
import 'dream_card.dart' as dream_card;
import 'dream_bottom_sheet.dart';
import 'dream_list_empty.dart';

class DreamByDate extends StatefulWidget {
  const DreamByDate({super.key});

  @override
  State<DreamByDate> createState() => _DreamByDateState();
}

class _DreamByDateState extends State<DreamByDate> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final _selectedDate = Provider.of<CalendarProvider>(context).selectedDate;
    final btnProvider = Provider.of<ButtonProvider>(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream:
            firestore
                .collection('users')
                .doc(auth.currentUser?.uid)
                .collection('dreams')
                .where(
                  'timestamp',
                  isGreaterThanOrEqualTo: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                  ),
                )
                .where(
                  'timestamp',
                  isLessThan: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day + 1,
                  ),
                )
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final dreams = snapshot.data?.docs ?? [];
          int dreamCount = dreams.length;

          return dreams.isEmpty
              ? DreamListEmpty(btnProvider: btnProvider)
              : ListView.builder(
                itemCount: dreamCount, // Use the variable here
                itemBuilder: (context, index) {
                  final dream = dreams[index];
                  return GestureDetector(
                    onLongPress: () async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Confirmar Eliminación',
                              style: RobotoTextStyle.titleStyle(Colors.black87),
                            ),
                            content: Text(
                              '¿Estás seguro de que deseas eliminar este sueño?',
                              style: RobotoTextStyle.subtitleStyle(
                                Colors.grey.shade600,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: Text(
                                  'Cancelar',
                                  style: RobotoTextStyle.smallTextStyle(
                                    Colors.purple.shade300,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: Text(
                                  'Eliminar',
                                  style: RobotoTextStyle.smallTextStyle(
                                    Colors.red.shade400,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete == true) {
                        await firestore
                            .collection('users')
                            .doc(auth.currentUser?.uid)
                            .collection('dreams')
                            .doc(dream['dreamId'])
                            .delete();
                        print('Dream deleted');
                      }
                    },
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DreamBottomSheet(
                            btnProvider: btnProvider,
                            dream: dream,
                          );
                        },
                      );
                    },
                    child: dream_card.DreamCard(
                      btnProvider: btnProvider,
                      dream: dream,
                    ),
                  );
                },
              );
        },
      ),
    );
  }
}
