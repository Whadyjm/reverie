import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudioButton extends StatefulWidget {
  const AudioButton({super.key});

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000).withAlpha(10),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.purple.shade300,
                Colors.indigo.shade100,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.mic_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}
