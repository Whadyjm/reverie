import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillow/provider/calendar_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CalendarTimeline extends StatefulWidget {
  CalendarTimeline({super.key});

  @override
  State<CalendarTimeline> createState() => _CalendarTimelineState();
}

class _CalendarTimelineState extends State<CalendarTimeline> {
  @override
  Widget build(BuildContext context) {
    final _selectedDate = Provider.of<CalendarProvider>(context);
    final selectedDate = _selectedDate.selectedDate;

    return Padding(
      padding: const EdgeInsets.only(top:30),
      child: EasyDateTimeLinePicker.itemBuilder(
        timelineOptions: TimelineOptions(
          height: 100, // the height of the timeline
        ),
        locale: Locale('es', 'ES'),
        headerOptions: HeaderOptions(headerType: HeaderType.none),
        firstDate: DateTime(2025, 1, 1),
        lastDate: DateTime.now(),
        focusedDate: selectedDate,
        itemExtent: 100,
        itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
          return InkResponse(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.grey.shade200, Colors.purple.shade200, Colors.purple.shade200, Colors.indigo.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(DateFormat('EEEE', 'es_ES').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text('${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w800,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        onDateChange: (date) {
          setState(() {
            print(date);
            _selectedDate.setSelectedDate(date);
          });
        },
      ),
    );
  }
}
