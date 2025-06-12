import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../provider/button_provider.dart';

class DreamDialog extends StatelessWidget {
  const DreamDialog({
    super.key,
    required this.btnProvider,
    required this.dream,
  });

  final ButtonProvider btnProvider;
  final QueryDocumentSnapshot<Object?> dream;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor:
          btnProvider.isButtonEnabled ? Colors.grey.shade900 : Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Título generado por IA',
            style: TextStyle(
              color:
                  btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade800,
              fontFamily: 'roboto',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Divider(),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          dream['text'],
          style: TextStyle(
            color:
                btnProvider.isButtonEnabled
                    ? Colors.white
                    : Colors.grey.shade800,
            fontFamily: 'roboto',
            fontSize: 16,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Iconsax.arrow_left_2_copy, color: btnProvider.isButtonEnabled ? Colors.white70:null,),
        ),
        const SizedBox(width: 15),
        OutlinedButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: () {},
          icon: Icon(Iconsax.magic_star, color: Colors.amber),
          label: Text(
            'Analizar sueño',
            style: TextStyle(
              color:
                  btnProvider.isButtonEnabled
                      ? Colors.white
                      : Colors.grey.shade800,
              fontFamily: 'roboto',
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
