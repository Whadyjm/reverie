import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/style/text_style.dart';

import '../provider/button_provider.dart';

class DreamBottomSheet extends StatefulWidget {
  const DreamBottomSheet({
    super.key,
    required this.btnProvider,
    required this.dream,
  });

  final ButtonProvider btnProvider;
  final QueryDocumentSnapshot<Object?> dream;

  @override
  State<DreamBottomSheet> createState() => _DreamBottomSheetState();
}

class _DreamBottomSheetState extends State<DreamBottomSheet> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            widget.btnProvider.isButtonEnabled
                ? Colors.grey.shade900
                : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.dream['title'],
            style: AppTextStyle.subtitleStyle(
              widget.btnProvider.isButtonEnabled
                  ? Colors.white
                  : Colors.grey.shade700,
            ),
          ),
          const Divider(),
          SingleChildScrollView(
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Iconsax.arrow_left_2_copy,
                  color:
                      widget.btnProvider.isButtonEnabled
                          ? Colors.white70
                          : null,
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
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    backgroundColor:
                        widget.btnProvider.isButtonEnabled
                            ? Colors.grey.shade900
                            : Colors.white,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Análisis del sueño',
                                  style: AppTextStyle.subtitleStyle(
                                    widget.btnProvider.isButtonEnabled
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const Divider(),
                              SingleChildScrollView(
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
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:Colors.purple.shade400,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Cerrar',
                                      style: RobotoTextStyle.smallTextStyle(
                                        widget.btnProvider.isButtonEnabled
                                            ? Colors.white
                                            : Colors.grey.shade800,
                                      )
                                    ),
                                  ),
                                  RatingBar(
                                    size: 32,
                                    filledIcon: Icons.star_rounded,
                                    emptyIcon: Icons.star_border_rounded,
                                    onRatingChanged: (value) => debugPrint('$value'),
                                    initialRating: 0,
                                    maxRating: 5,
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon:
                    isLoading
                        ? SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple.shade300,
                            ),
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
          ),
        ],
      ),
    );
  }
}
