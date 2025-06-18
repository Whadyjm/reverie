import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/button_provider.dart';
import '../provider/calendar_provider.dart';
import '../provider/dream_provider.dart';
import 'dream_card.dart';
import 'dream_dialog.dart';
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
                .collection('users').doc(auth.currentUser?.uid).collection('dreams')
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DreamDialog(btnProvider: btnProvider, dream: dream);
                        },
                      );
                    },
                    child: DreamCard(btnProvider: btnProvider, dream: dream),
                  );
                },
              );
        },
      ),
    );
  }
}


