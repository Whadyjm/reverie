import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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

  Stream<int> fetchDreamCountByDate(DateTime date) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('dreams')
        .where(
      'timestamp',
      isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day),
    )
        .where(
      'timestamp',
      isLessThan: DateTime(date.year, date.month, date.day + 1),
    )
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }

  Future<void> _showCustomCalendar(BuildContext context, DateTime initialDate) async {
    DateTime selectedDate = initialDate;
    bool isYearPicker = false;
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

    final DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 300,
                  color: btnProvider.isButtonEnabled
                      ? Colors.grey.shade900
                      : Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with month/year switcher
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedDate = DateTime(
                                    selectedDate.year - (isYearPicker ? 1 : 0),
                                    selectedDate.month - (isYearPicker ? 0 : 1),
                                    1,
                                  );
                                });
                              },
                            ),
                            InkWell(
                              //onTap: () => setState(() => isYearPicker = !isYearPicker),
                              child: Text(
                                isYearPicker
                                    ? selectedDate.year.toString()
                                    : DateFormat('MMMM y', 'es_ES').format(selectedDate),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: btnProvider.isButtonEnabled
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedDate = DateTime(
                                    selectedDate.year + (isYearPicker ? 1 : 0),
                                    selectedDate.month + (isYearPicker ? 0 : 1),
                                    1,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Month/Year grid
                      if (isYearPicker)
                        _buildYearGrid(selectedDate, setState, context)
                      else
                        _buildMonthGrid(selectedDate, (newDate) {
                          Navigator.pop(context, newDate);
                        }, context),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (pickedDate != null) {
      calendarProvider.setSelectedDate(pickedDate);
    }
  }

  Widget _buildMonthGrid(DateTime selectedDate, Function(DateTime) onMonthSelected, BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(12, (index) {
        final monthDate = DateTime(selectedDate.year, index + 1, 1);
        final isSelected = selectedDate.month == index + 1;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onMonthSelected(monthDate),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? (btnProvider.isButtonEnabled
                    ? Colors.purple.shade400
                    : Colors.purple.shade300)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (btnProvider.isButtonEnabled
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2)),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                DateFormat('MMM', 'es_ES').format(monthDate),
                style: TextStyle(
                  color: isSelected
                      ? (btnProvider.isButtonEnabled
                      ? Colors.black
                      : Colors.white)
                      : (btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade800),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildYearGrid(DateTime selectedDate, StateSetter setState, BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final currentYear = selectedDate.year;
    final yearRange = List.generate(12, (index) => currentYear - 5 + index);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: yearRange.map((year) {
        final isSelected = selectedDate.year == year;

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                selectedDate = DateTime(year, selectedDate.month, 1);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? (btnProvider.isButtonEnabled
                    ? Colors.purple.shade400
                    : Colors.purple.shade300)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (btnProvider.isButtonEnabled
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2)),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                year.toString(),
                style: TextStyle(
                  color: isSelected
                      ? (btnProvider.isButtonEnabled
                      ? Colors.black
                      : Colors.white)
                      : (btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade800),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _selectedDate = Provider.of<CalendarProvider>(context);
    final selectedDate = _selectedDate.selectedDate;
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);

    return EasyDateTimeLinePicker.itemBuilder(
      timelineOptions: TimelineOptions(
        height: 150,
      ),
      locale: Locale('es', 'ES'),
      headerOptions: HeaderOptions(
          headerBuilder: (context, date, onTap) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
              child: InkWell(
                onTap: () => _showCustomCalendar(context, date),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: btnProvider.isButtonEnabled
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: btnProvider.isButtonEnabled
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM y', 'es_ES').format(date),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: btnProvider.isButtonEnabled
                              ? Colors.white
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: btnProvider.isButtonEnabled
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.shade300,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(0, 0),
                    spreadRadius: 1,
                  ),
                ],
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    Colors.grey.shade200.withOpacity(0.8),
                    Colors.purple.shade200.withOpacity(0.8),
                    Colors.purple.shade200.withOpacity(0.8),
                    Colors.indigo.shade300.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
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
                          color: isSelected
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
                  StreamBuilder<int>(
                    stream: fetchDreamCountByDate(date),
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
        Provider.of<CalendarProvider>(
          context,
          listen: false,
        ).setSelectedDate(date);
      },
    );
  }
}