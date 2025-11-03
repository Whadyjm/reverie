import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Removed unused imports: provider, calendar_provider, skeletonizer

class DreamCountDot extends StatefulWidget {
  const DreamCountDot({super.key, required this.stream, required this.date});

  final Stream<int> stream;
  final DateTime date;

  @override
  State<DreamCountDot> createState() => _DreamCountDotState();
}

class _DreamCountDotState extends State<DreamCountDot> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final targetDate = widget.date;
    FirebaseAuth auth = FirebaseAuth.instance;
    return StreamBuilder<int>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: TextStyle(fontSize: 12, color: Colors.red.shade500),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream:
              firestore
                  .collection('users')
                  .doc(auth.currentUser?.uid)
                  .collection('dreams')
                  .where(
                    'timestamp',
                    isGreaterThanOrEqualTo: DateTime(
                      targetDate.year,
                      targetDate.month,
                      targetDate.day,
                    ),
                  )
                  .where(
                    'timestamp',
                    isLessThan: DateTime(
                      targetDate.year,
                      targetDate.month,
                      targetDate.day + 1,
                    ),
                  )
                  .snapshots(),
          builder: (context, asyncSnapshot) {
            final dreams = asyncSnapshot.data?.docs ?? [];

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(snapshot.data ?? 0, (index) {
                String classification = '';
                if (index < dreams.length) {
                  try {
                    final doc = dreams[index];
                    final data = doc.data();
                    if (data is Map<String, dynamic>) {
                      classification =
                          (data['classification'] ?? '').toString();
                    } else {
                      classification = doc.get('classification').toString();
                    }
                  } catch (_) {
                    classification = '';
                  }
                }

                final dotColor =
                    classification == 'Pesadilla'
                        ? Colors.indigo.shade800
                        : Colors.indigo.shade400;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.purple.shade200, blurRadius: 1),
                        BoxShadow(color: Colors.indigo.shade400, blurRadius: 1),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        );
      },
    );
  }
}
