import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../provider/button_provider.dart';

class DreamListEmpty extends StatelessWidget {
  const DreamListEmpty({
    super.key,
    required this.btnProvider,
  });

  final ButtonProvider btnProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                '¿Qué soñaste hoy?',
                style: TextStyle(
                  fontFamily: 'instrumental',
                  fontSize: 40,
                  color:
                  btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
            ),
            Image.asset(
              height: 350,
              'assets/pilo_bed.png',
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ),
    );
  }
}