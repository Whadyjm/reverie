import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillow/provider/calendar_provider.dart';
import 'package:pillow/style/text_style.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/button_provider.dart';

class CalendarTimeline extends StatefulWidget {
  CalendarTimeline({super.key});

  @override
  State<CalendarTimeline> createState() => _CalendarTimelineState();
}

class _CalendarTimelineState extends State<CalendarTimeline> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<int> fetchDreamCountByDate(DateTime date) async {

    try {
      final querySnapshot =
      await firestore
          .collection('users').doc(auth.currentUser?.uid).collection('dreams')
          .where(
        'timestamp',
        isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day),
      )
          .where(
        'timestamp',
        isLessThan: DateTime(date.year, date.month, date.day + 1),
      )
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }

  }

  @override
  Widget build(BuildContext context) {
    final _selectedDate = Provider.of<CalendarProvider>(context);
    final selectedDate = _selectedDate.selectedDate;
    final btnProvider =
        Provider.of<ButtonProvider>(context, listen: false);

    return EasyDateTimeLinePicker.itemBuilder(
      timelineOptions: TimelineOptions(
        height: 150, // the height of the timeline
      ),
      locale: Locale('es', 'ES'),
      headerOptions: HeaderOptions(
          headerBuilder: (context, date, onTap){
            return Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
              child: InkWell(onTap: onTap, child: Text(DateFormat.yMMMM().format(date), style: RobotoTextStyle.smallTextStyle(btnProvider.isButtonEnabled ? Colors.white:Colors.grey.shade700),)),
            );
          }
      ),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now(),
      focusedDate: selectedDate,
      itemExtent: 100,
      itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: InkResponse(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: btnProvider.isButtonEnabled ? Colors.black54:Colors.grey.shade300,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            Colors.grey.shade200,
                            Colors.purple.shade200,
                            Colors.purple.shade200,
                            Colors.indigo.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color: isSelected ? null : btnProvider.isButtonEnabled? Colors.white70:Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Center(
                      child: Text(
                        DateFormat('EEEE', 'es_ES').format(date),
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.w800,
                      fontSize: 40,
                    ),
                  ),
                  FutureBuilder<int>(
                    future: fetchDreamCountByDate(date),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade500,
                          ),
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            snapshot.data ?? 0,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purple.shade300,
                                      Colors.indigo,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.shade100,
                                      offset: Offset(-2, -2),
                                      blurRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: Colors.indigo.shade400,
                                      offset: Offset(2, 2),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onDateChange: (date) {
        setState(() {
          print(date);
          Provider.of<CalendarProvider>(
            context,
            listen: false,
          ).setSelectedDate(date);
        });
      },
    );
  }
}
