import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:provider/provider.dart';
import 'package:reverie/style/text_style.dart';
import '../provider/button_provider.dart';
import '../provider/calendar_provider.dart';
import 'dream_card.dart' as dream_card;
import 'dream_bottom_sheet.dart';

class DreamByDate extends StatefulWidget {
  const DreamByDate({super.key, this.suscription});

  final String? suscription;
  @override
  State<DreamByDate> createState() => _DreamByDateState();
}

class _DreamByDateState extends State<DreamByDate> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLongPress = false;

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
              ? FadeIn(
                duration: Duration(milliseconds: 800),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '¿Que soñaste hoy?',
                        style: AppTextStyle.titleStyle(
                          Colors.white.withAlpha(250),
                        ),
                      ),
                      Image.asset(
                        'assets/notebook.png',
                        width: 300,
                        height: 300,
                      ),
                    ],
                  ),
                ),
              )
              : FadeIn(
                duration: Duration(milliseconds: 800),
                child: ListView.builder(
                  itemCount: dreamCount,
                  itemBuilder: (context, index) {
                    final dream = dreams[index];

                    return GestureDetector(
                      onLongPress: () async {
                        final can = await Haptics.canVibrate();

                        if (!can) {
                          return;
                        }
                        await Haptics.vibrate(HapticsType.success);
                        setState(() {
                          isLongPress = !isLongPress;
                        });
                        await Future.delayed(Duration(seconds: 20));
                        setState(() {
                          isLongPress = false;
                        });
                      },
                      onTap: () {
                        setState(() {
                          isLongPress = false;
                        });
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DreamBottomSheet(
                              btnProvider: btnProvider,
                              dream: dream,
                              suscription: widget.suscription,
                            );
                          },
                        );
                      },
                      child: dream_card.DreamCard(
                        btnProvider: btnProvider,
                        dream: dream,
                        isLongPress: isLongPress,
                      ),
                    );
                  },
                ),
              );
        },
      ),
    );
  }
}
