import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DreamCountDot extends StatefulWidget {
  const DreamCountDot({super.key, required this.stream});

  final Stream<int> stream;

  @override
  State<DreamCountDot> createState() => _DreamCountDotState();
}

class _DreamCountDotState extends State<DreamCountDot> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            'Error',
            style: TextStyle(fontSize: 12, color: Colors.red.shade500),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            snapshot.data ?? 0,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade300, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade100,
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
      },
    );
  }
}
