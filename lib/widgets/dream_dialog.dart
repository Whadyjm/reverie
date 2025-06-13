import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/style/text_style.dart';

import '../provider/button_provider.dart';

class DreamDialog extends StatefulWidget {
  const DreamDialog({
    super.key,
    required this.btnProvider,
    required this.dream,
  });

  final ButtonProvider btnProvider;
  final QueryDocumentSnapshot<Object?> dream;

  @override
  State<DreamDialog> createState() => _DreamDialogState();
}

class _DreamDialogState extends State<DreamDialog> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor:
          widget.btnProvider.isButtonEnabled ? Colors.grey.shade900 : Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dream['title'],
            style: AppTextStyle.subtitleStyle(
              widget.btnProvider.isButtonEnabled ? Colors.white : Colors.grey.shade700,
            ),
          ),
          const Divider(),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          widget.dream['text'],
          style: TextStyle(
            color:
                widget.btnProvider.isButtonEnabled
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
          icon: Icon(
            Iconsax.arrow_left_2_copy,
            color: widget.btnProvider.isButtonEnabled ? Colors.white70 : null,
          ),
        ),
        const SizedBox(width: 15),
OutlinedButton.icon(
          iconAlignment: IconAlignment.end,
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            await Future.delayed(const Duration(seconds: 2));
            setState(() {
              isLoading = false;
            });
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      widget.btnProvider.isButtonEnabled
                          ? Colors.grey.shade900
                          : Colors.white,
                  title: Text(
                    'Análisis del sueño',
                    style: AppTextStyle.subtitleStyle(
                      widget.btnProvider.isButtonEnabled
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Text(
                      widget.dream['analysis'],
                      style: TextStyle(
                        color:
                            widget.btnProvider.isButtonEnabled
                                ? Colors.white
                                : Colors.grey.shade800,
                        fontFamily: 'roboto',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cerrar',
                        style: TextStyle(
                          color:
                              widget.btnProvider.isButtonEnabled
                                  ? Colors.white
                                  : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          icon: isLoading
              ? SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade300),
                  ),
                )
              : Icon(Iconsax.magic_star, color: Colors.amber),
          label: Text(
            'Ver análisis',
            style: TextStyle(
              color:
                  widget.btnProvider.isButtonEnabled
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
