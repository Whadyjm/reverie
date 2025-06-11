import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/calendar_provider.dart';
import '../provider/dream_provider.dart';

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
          final dreams = snapshot.data?.docs ?? [];
          int dreamCount = dreams.length;

          return dreams.isEmpty
              ? Padding(
                padding: const EdgeInsets.only(top: 50),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          'Sin sueños... por ahora',
                          style: TextStyle(
                            fontFamily: 'instrumental',
                            fontSize: 40,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Image.asset(
                        height: 350,
                        'assets/bed-side.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                itemCount: dreamCount, // Use the variable here
                itemBuilder: (context, index) {
                  final dream = dreams[index];
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 4,
                            offset: Offset(2,1),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(8),
                      height: 100,
                      width: 200,
                      child: Text(
                        dream['text'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.w500,
                          foreground: Paint()
                            ..shader = LinearGradient(
                              colors: [
                                Colors.transparent.withAlpha(200),
                                Colors.transparent.withAlpha(150),
                                Colors.transparent.withAlpha(50),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(Rect.fromLTWH(0, 0, 200, 100)),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ); /*ListTile(
                title: Text(
                  dream['text'],
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                    fontSize: 20,
                  ),
                ),
              );*/
                },
              );
        },
      ),
    );
  }
}
