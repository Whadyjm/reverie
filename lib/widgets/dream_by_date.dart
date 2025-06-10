import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';

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

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream:
            firestore
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final dreams = snapshot.data?.docs ?? [];
          return dreams.isEmpty
              ? Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sin sueños',
                      style: TextStyle(
                        fontFamily: 'instrumental',
                        fontSize: 40,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Image.asset(
                      height: 400,
                      'assets/bed-side.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: dreams.length,
                itemBuilder: (context, index) {
                  final dream = dreams[index];
                  return ListTile(title: Text(dream['text']));
                },
              );
        },
      ),
    );
  }
}
