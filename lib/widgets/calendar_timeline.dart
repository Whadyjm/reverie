import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:reverie/provider/calendar_provider.dart';
import 'package:reverie/widgets/dream_count_dot.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
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
  bool openDreamPanel = false;

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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final monthDate = DateTime(selectedDate.year, index + 1, 1);
        final isSelected = selectedDate.month == index + 1;
        final isFutureMonth =
            selectedDate.year > currentYear ||
            (selectedDate.year == currentYear && (index + 1) > currentMonth);
        final isCurrentMonth =
            (selectedDate.year == currentYear && (index + 1) == currentMonth);

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 1, end: isSelected ? 1.05 : 1),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return GestureDetector(
              onTap: isFutureMonth ? null : () => onMonthSelected(monthDate),
              child: Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient:
                        isSelected
                            ? LinearGradient(
                              colors: [
                                Colors.purple.shade400,
                                Colors.purple.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    color: !isSelected ? Colors.white.withOpacity(0.08) : null,
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.transparent
                              : (isCurrentMonth
                                  ? Colors.purpleAccent.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.1)),
                      width: isCurrentMonth ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.5),
                                blurRadius: 14,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                    backgroundBlendMode: isSelected ? null : BlendMode.overlay,
                  ),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: isFutureMonth ? 0.35 : 1,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 1.3,
                        color:
                            isSelected
                                ? Colors.white
                                : (isFutureMonth
                                    ? Colors.grey.shade500
                                    : Colors.purple.shade200),
                      ),
                      child: Text(
                        DateFormat(
                          'MMM',
                          'es_ES',
                        ).format(monthDate).toUpperCase(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
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
      timelineOptions: TimelineOptions(height: 115),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
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
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showCustomCalendar(context, date),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'MMMM y',
                                'es_ES',
                              ).format(date).toUpperCase(),
                              style: RobotoTextStyle.small2TextStyle(
                                Colors.white,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 250),
                              turns: openDreamPanel ? 0.5 : 0,
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    StreamBuilder(
                      stream: getDreamCountByMonth(_currentDisplayedMonth),
                      builder: (context, snapshot) {
                        int dreamCount = snapshot.data ?? 0;
                        if (dreamCount == 0) return const SizedBox.shrink();
                        return Stack(
                          children: [
                            _badgeIcon(),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() => openDreamPanel = true);
                                    _showPanelDreams(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white.withOpacity(0.08),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.15),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        'PANEL DE SUEÑOS',
                                        style: RobotoTextStyle.small2TextStyle(
                                          Colors.white,
                                        ).copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
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
      itemExtent: 80,
      itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
        return StreamBuilder(
          stream: fetchDreamCountByDate(date),
          builder: (context, snapshot) {
            final countDate = snapshot.data;
            return countDate == 0
                ? Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: InkResponse(
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(20),
                          width: 1,
                        ),
                        gradient:
                            isSelected
                                ? btnProvider.isButtonEnabled
                                    ? LinearGradient(
                                      colors: [
                                        Color(0xFF1A003F),
                                        Color(0xFF2E1A5E),
                                        Color(0xFF4A3A7C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                    : LinearGradient(
                                      colors: [
                                        Color(0xFF0D1B2A),
                                        Color(0xFF5D3A9B),
                                      ],
                                    )
                                : LinearGradient(
                                  colors: [
                                    Colors.white.withAlpha(50),
                                    Colors.white.withAlpha(50),
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
                                      isSelected
                                          ? Colors.white
                                          : Colors.white.withAlpha(100),
                                  fontFamily: 'roboto',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withAlpha(100),
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: InkResponse(
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(20),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
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
                                ? btnProvider.isButtonEnabled
                                    ? LinearGradient(
                                      colors: [
                                        Color(0xFF1A003F),
                                        Color(0xFF2E1A5E),
                                        Color(0xFF4A3A7C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                    : LinearGradient(
                                      colors: [
                                        Color(0xFF0D1B2A),
                                        Color(0xFF5D3A9B),
                                      ],
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
                                      isSelected
                                          ? Colors.white
                                          : Colors.white.withAlpha(100),
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
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withAlpha(100),
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                            ),
                          ),
                          const SizedBox(height: 3),
                          DreamCountDot(stream: fetchDreamCountByDate(date)),
                        ],
                      ),
                    ),
                  ),
                );
          },
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
      transitionDuration: const Duration(milliseconds: 350),
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
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 32,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✨ Glow background (soft aura behind the dialog)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.15),
                            Colors.transparent,
                          ],
                          radius: 1.2,
                          center: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),

                  // ✨ Main dialog with glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.08,
                            ), // glass border
                            width: 1.2,
                          ),
                          gradient:
                              isDark
                                  ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF1E1A29).withOpacity(0.92),
                                      const Color(0xFF2A2340).withOpacity(0.88),
                                      const Color(0xFF141218).withOpacity(0.94),
                                    ],
                                  )
                                  : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(
                                        0xFFFFFFFF,
                                      ).withOpacity(0.85), // base white
                                      const Color(
                                        0xFFDAD6FF,
                                      ).withOpacity(0.9), // soft violet glow
                                      const Color(
                                        0xFFE3F0FF,
                                      ).withOpacity(0.95), // icy blue tint
                                    ],
                                  ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isDark
                                      ? Colors.black.withOpacity(0.45)
                                      : Colors.deepPurple.withOpacity(0.12),
                              blurRadius: 30,
                              spreadRadius: 2,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Row(
                              children: [
                                Text(
                                  '🌘 Panel de sueños',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF3B2E5A),
                                  ),
                                ),
                                const Spacer(),
                                // Close button
                                IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : const Color(0xFF5E4C7A),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),

                            // Subtitle
                            Text(
                              DateFormat(
                                'MMMM y',
                                'es_ES',
                              ).format(_currentDisplayedMonth).toUpperCase(),
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                                color:
                                    isDark
                                        ? Colors.grey.shade400
                                        : const Color(0xFF7D6C92),
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Divider(thickness: 0.6, height: 1),

                            const SizedBox(height: 20),

                            // Dream count
                            StreamBuilder<int>(
                              stream: getDreamCountByMonth(
                                _currentDisplayedMonth,
                              ),
                              builder: (context, snapshot) {
                                final dreamCount = snapshot.data ?? 0;
                                if (dreamCount == 0)
                                  return const SizedBox.shrink();
                                return Row(
                                  children: [
                                    const Text(
                                      '🌙 ',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      '$dreamCount ${dreamCount == 1 ? "sueño registrado" : "sueños registrados"}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
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

                            // Emotion of the month
                            StreamBuilder(
                              stream: monthlyEmotion(
                                _currentDisplayedMonth.month,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const SizedBox.shrink();
                                }
                                return Skeletonizer(
                                  effect: const ShimmerEffect(
                                    baseColor: Colors.grey,
                                    highlightColor: Colors.white,
                                    duration: Duration(seconds: 1),
                                  ),
                                  enabled: snapshot.hasData ? false : true,
                                  child:
                                      snapshot.data != ''
                                          ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '🎭 ',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Emoción del mes: ${snapshot.data}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        isDark
                                                            ? Colors
                                                                .grey
                                                                .shade100
                                                            : const Color(
                                                              0xFF4A3B6A,
                                                            ),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _badgeIcon() {
    return StreamBuilder(
      stream: monthlyEmotion(_currentDisplayedMonth.month),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final tomorrow = now.add(const Duration(days: 1));
        final isLastDayOfMonth = now.month != tomorrow.month;

        if (snapshot.hasData && !openDreamPanel && isLastDayOfMonth) {
          return AnimatedScale(
            scale: 1.05,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.purpleAccent.shade200.withAlpha(50),
                    Colors.deepPurple.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(7),
              child: const Icon(
                Iconsax.notification,
                size: 16,
                color: Colors.white,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
