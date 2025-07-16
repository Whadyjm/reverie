import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillow/style/text_style.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../provider/button_provider.dart';
import '../provider/calendar_provider.dart';
import 'dream_card.dart' as dream_card;
import 'dream_bottom_sheet.dart';
import 'dream_list_empty.dart';

class DreamByDate extends StatefulWidget {
  const DreamByDate({super.key, this.suscription});

  final String? suscription;
  @override
  State<DreamByDate> createState() => _DreamByDateState();
}

class _DreamByDateState extends State<DreamByDate> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isLongPress = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    });
  }

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            _isLoading = true;
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            _isLoading = false;
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final dreams = snapshot.data?.docs ?? [];
          int dreamCount = dreams.length;

          return dreams.isEmpty && !_isLoading
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Que soñaste hoy?',
                    style: AppTextStyle.titleStyle(
                      btnProvider.isButtonEnabled
                          ? Colors.white.withAlpha(200)
                          : Colors.grey.shade700,
                    ),
                  ),
                  Image.asset('assets/notebook.png', width: 300, height: 300),
                ],
              )
              : FadeIn(
                duration: Duration(milliseconds: 800),
                child: Skeletonizer(
                  containersColor:
                      btnProvider.isButtonEnabled
                          ? Colors.purple.shade800.withAlpha(40)
                          : Colors.purple.shade100.withAlpha(70),
                  enabled: _isLoading,
                  ignoreContainers: false,
                  child: ListView.builder(
                    itemCount: dreamCount,
                    itemBuilder: (context, index) {
                      final dream = dreams[index];
                      if (_isLoading) {
                        return dream_card.DreamCard(
                          btnProvider: btnProvider,
                          dream: dream,
                          isLongPress: false,
                        );
                      }

                      return GestureDetector(
                        onLongPress: () async {
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
                ),
              );
        },
      ),
    );
  }
}
