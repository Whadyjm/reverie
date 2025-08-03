import 'dart:ffi';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:reverie/provider/calendar_provider.dart';
import 'package:reverie/widgets/dream_count_dot.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../provider/button_provider.dart';
import '../style/text_style.dart';

class CalendarTimeline extends StatefulWidget {
  CalendarTimeline({super.key, this.emotionResult});

  final String? emotionResult;

  @override
  State<CalendarTimeline> createState() => _CalendarTimelineState();
}

class _CalendarTimelineState extends State<CalendarTimeline> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  DateTime _currentDisplayedMonth = DateTime.now();
  bool _isMonthSelection = false;

  Stream<int> getDreamCountByMonth(DateTime month) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(0);
    }

    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('dreams')
        .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((e) {
          print('Error getting dream count: $e');
          return 0;
        });
  }

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

  Stream<String> monthlyEmotion(int date) {
    return firestore
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('monthlyEmotions')
        .where('month', isEqualTo: date)
        .snapshots()
        .map((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            return querySnapshot.docs.first.get('emotion');
          }
          return '';
        });
  }

  Future<void> _showCustomCalendar(
    BuildContext context,
    DateTime initialDate,
  ) async {
    DateTime selectedDate = initialDate;
    bool isYearPicker = false;

    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final calendarProvider = Provider.of<CalendarProvider>(
      context,
      listen: false,
    );
    final isDark = btnProvider.isButtonEnabled;

    final DateTime? pickedDate = await showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Calendario',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 40,
              ),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              isDark
                                  ? [
                                    const Color(0xFF1A1124),
                                    const Color(0xFF1C1733),
                                    const Color(0xFF222222),
                                  ]
                                  : [Colors.grey.shade100, Colors.white],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_left,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = DateTime(
                                      selectedDate.year -
                                          (isYearPicker ? 1 : 0),
                                      selectedDate.month -
                                          (isYearPicker ? 0 : 1),
                                      1,
                                    );
                                  });
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() => isYearPicker = !isYearPicker);
                                },
                                child: Text(
                                  DateFormat(
                                    'MMMM y',
                                    'es_ES',
                                  ).format(selectedDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color:
                                      isDark
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = DateTime(
                                      selectedDate.year +
                                          (isYearPicker ? 1 : 0),
                                      selectedDate.month +
                                          (isYearPicker ? 0 : 1),
                                      1,
                                    );
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (isYearPicker)
                            _buildYearGrid(selectedDate, setState, context)
                          else
                            _buildMonthGrid(selectedDate, (newDate) {
                              Navigator.pop(
                                context,
                                DateTime(newDate.year, newDate.month, 1),
                              );
                            }, context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _currentDisplayedMonth = pickedDate;
        _isMonthSelection = true;
      });
      calendarProvider.setSelectedDate(pickedDate);
    }
  }

  Widget _buildMonthGrid(
    DateTime selectedDate,
    Function(DateTime) onMonthSelected,
    BuildContext context,
  ) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: List.generate(12, (index) {
        final monthDate = DateTime(selectedDate.year, index + 1, 1);
        final isSelected = selectedDate.month == index + 1;
        final isFutureMonth =
            selectedDate.year > currentYear ||
            (selectedDate.year == currentYear && (index + 1) > currentMonth);

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isFutureMonth ? null : () => onMonthSelected(monthDate),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? (btnProvider.isButtonEnabled
                            ? Colors.purple.shade400
                            : Colors.purple.shade300)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isSelected
                          ? Colors.transparent
                          : (btnProvider.isButtonEnabled
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2)),
                ),
              ),
              alignment: Alignment.center,
              child: Opacity(
                opacity: isFutureMonth ? 0.5 : 1.0,
                child: Text(
                  DateFormat('MMM', 'es_ES').format(monthDate),
                  style: TextStyle(
                    color:
                        isSelected
                            ? (btnProvider.isButtonEnabled
                                ? Colors.black
                                : Colors.white)
                            : (isFutureMonth
                                ? Colors.grey
                                : (btnProvider.isButtonEnabled
                                    ? Colors.white
                                    : Colors.grey.shade800)),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildYearGrid(
    DateTime selectedDate,
    StateSetter setState,
    BuildContext context,
  ) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final currentYear = selectedDate.year;
    final yearRange = List.generate(12, (index) => currentYear - 5 + index);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children:
          yearRange.map((year) {
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
                    color:
                        isSelected
                            ? (btnProvider.isButtonEnabled
                                ? Colors.purple.shade400
                                : Colors.purple.shade300)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isSelected
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
                      color:
                          isSelected
                              ? (btnProvider.isButtonEnabled
                                  ? Colors.black
                                  : Colors.white)
                              : (btnProvider.isButtonEnabled
                                  ? Colors.white
                                  : Colors.grey.shade800),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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
      timelineOptions: TimelineOptions(height: 150),
      locale: Locale('es', 'ES'),
      headerOptions: HeaderOptions(
        headerBuilder: (context, date, onTap) {
          if (_currentDisplayedMonth.month != date.month ||
              _currentDisplayedMonth.year != date.year) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentDisplayedMonth = date;
              });
            });
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    btnProvider.isButtonEnabled
                        ? Colors.white.withAlpha(10)
                        : Colors.grey.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      btnProvider.isButtonEnabled
                          ? Colors.white.withAlpha(30)
                          : Colors.grey.withAlpha(30),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color:
                        btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showCustomCalendar(context, date),
                    child: Text(
                      DateFormat('MMMM y', 'es_ES').format(date),
                      style: RobotoTextStyle.small2TextStyle(
                        btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color:
                        btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade700,
                  ),
                  const Spacer(),
                  StreamBuilder(
                    stream: getDreamCountByMonth(_currentDisplayedMonth),
                    builder: (context, snapshot) {
                      int dreamCount = snapshot.data ?? 0;
                      return (dreamCount != 0)
                          ? Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showPanelDreams(context),
                                child: Text(
                                  'Panel de sueños',
                                  style: RobotoTextStyle.small2TextStyle(
                                    btnProvider.isButtonEnabled
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color:
                                    btnProvider.isButtonEnabled
                                        ? Colors.white
                                        : Colors.grey.shade700,
                              ),
                            ],
                          )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now(),
      focusedDate:
          _isMonthSelection
              ? DateTime(
                _currentDisplayedMonth.year,
                _currentDisplayedMonth.month,
                1,
              )
              : selectedDate,
      itemExtent: 100,
      itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
        return Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: InkResponse(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(20), width: 1),
                boxShadow: [
                  BoxShadow(
                    color:
                        btnProvider.isButtonEnabled
                            ? Colors.black.withAlpha(20)
                            : Colors.grey.shade300,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withAlpha(20),
                    blurRadius: 5,
                    offset: Offset(0, 0),
                    spreadRadius: 1,
                  ),
                ],
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            Colors.grey.shade200.withAlpha(80),
                            Colors.purple.shade200.withAlpha(80),
                            Colors.purple.shade200.withAlpha(80),
                            Colors.indigo.shade300.withAlpha(80),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : LinearGradient(
                          colors: [
                            Colors.white.withAlpha(80),
                            Colors.white.withAlpha(80),
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
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
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
                  DreamCountDot(stream: fetchDreamCountByDate(date)),
                ],
              ),
            ),
          ),
        );
      },
      onDateChange: (date) {
        setState(() {
          _currentDisplayedMonth = date;
          _isMonthSelection = false;
        });
        Provider.of<CalendarProvider>(
          context,
          listen: false,
        ).setSelectedDate(date);
      },
    );
  }

  void _showPanelDreams(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final isDark = btnProvider.isButtonEnabled;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sueños',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 40,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient:
                        isDark
                            ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1124),
                                Color(0xFF1C1733),
                                Color(0xFF222222),
                              ],
                            )
                            : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF5F3FF), // lavanda muy suave
                                Color(0xFFEDE9FE), // gris perla
                                Color(0xFFFFFFFF), // blanco puro
                              ],
                            ),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌘 Panel de sueños',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF3B2E5A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat(
                          'MMMM y',
                          'es_ES',
                        ).format(_currentDisplayedMonth),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark
                                  ? Colors.grey.shade300
                                  : const Color(0xFF6B5E7A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      StreamBuilder<int>(
                        stream: getDreamCountByMonth(_currentDisplayedMonth),
                        builder: (context, snapshot) {
                          final dreamCount = snapshot.data ?? 0;
                          if (dreamCount == 0) return const SizedBox.shrink();
                          return Row(
                            children: [
                              const Text('🌙 ', style: TextStyle(fontSize: 18)),
                              Text(
                                '$dreamCount ${dreamCount == 1 ? "sueño registrado" : "sueños registrados"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isDark
                                          ? Colors.grey.shade100
                                          : const Color(0xFF4A3B6A),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      //if (widget.emotionResult?.isNotEmpty == true)
                      StreamBuilder(
                        stream: monthlyEmotion(_currentDisplayedMonth.month),
                        builder: (context, Snapshot) {
                          if (Snapshot.hasError) {
                            return Text('');
                          }
                          return Skeletonizer(
                            enabled: Snapshot.hasData ? false : true,
                            child:
                                Snapshot.data != ''
                                    ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '🎭 ',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Emoción del mes: ${Snapshot.data}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  isDark
                                                      ? Colors.grey.shade100
                                                      : const Color(0xFF4A3B6A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
