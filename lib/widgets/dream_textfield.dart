import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DreamTextfield extends StatefulWidget {
  const DreamTextfield({super.key, required this.dreamController});

  final TextEditingController dreamController;

  @override
  State<DreamTextfield> createState() => _DreamTextfieldState();
}

class _DreamTextfieldState extends State<DreamTextfield> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        autofocus: false,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          fontFamily: 'roboto',
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        controller: widget.dreamController,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            letterSpacing: 1.2,
            fontFamily: 'roboto',
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Anoche soñé con...',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
