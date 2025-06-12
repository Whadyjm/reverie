import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../provider/button_provider.dart';
import '../style/text_style.dart';

class DreamCard extends StatelessWidget {
  const DreamCard({super.key, required this.btnProvider, required this.dream});

  final ButtonProvider btnProvider;
  final QueryDocumentSnapshot<Object?> dream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
                  btnProvider.isButtonEnabled
                      ? Colors.black87
                      : Colors.grey.shade300,
              blurRadius: 4,
              offset: Offset(2, 1),
            ),
          ],
        ),
        height: 100,
        width: 200,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Título generado por IA',
                    style: RobotoTextStyle.subtitleStyle(Colors.grey.shade600),
                  ),
                ],
              ),
              Text(
                dream['text'],
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.w500,
                  foreground:
                      Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.transparent.withAlpha(200),
                            Colors.transparent.withAlpha(150),
                            Colors.transparent.withAlpha(50),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(Rect.fromLTWH(0, 0, 200, 100)),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
