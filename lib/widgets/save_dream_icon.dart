import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SaveDreamIcon extends StatefulWidget {
  const SaveDreamIcon({super.key});

  @override
  State<SaveDreamIcon> createState() => _SaveDreamIconState();
}

class _SaveDreamIconState extends State<SaveDreamIcon> {
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [
            Colors.indigo.shade100,
            Colors.purple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: const Icon(
        Icons.send_rounded,
        color: Colors.white,
      ),
    );
  }
}
