import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reverie/style/text_style.dart';
import 'package:reverie/widgets/dialogs/pricing_dialog.dart';
import 'package:reverie/widgets/threedotsloading.dart';

import '../provider/button_provider.dart';

class DreamBottomSheet extends StatefulWidget {
  const DreamBottomSheet({
    super.key,
    required this.btnProvider,
    required this.dream,
    this.suscription,
  });

  final ButtonProvider btnProvider;
  final QueryDocumentSnapshot<Object?> dream;
  final String? suscription;

  @override
  State<DreamBottomSheet> createState() => _DreamBottomSheetState();
}

class _DreamBottomSheetState extends State<DreamBottomSheet> {
  double currentRating = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentRating = widget.dream['rating']?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(top: 280),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.btnProvider.isButtonEnabled
              ? Colors.grey.shade900
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Iconsax.arrow_left_2_copy,
                      color: widget.btnProvider.isButtonEnabled
                          ? Colors.white70
                          : null,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      widget.dream['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.subtitleStyle(
                        widget.btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dream['text'],
                      style: TextStyle(
                        color: widget.btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade800,
                        fontFamily: 'roboto',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 50,
                      width: 500,
                      decoration: BoxDecoration(
                        color: btnProvider.isButtonEnabled
                            ? Colors.grey.shade700
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: btnProvider.isButtonEnabled
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.dream['emotions'],
                          style: RobotoTextStyle.smallTextStyle(
                            btnProvider.isButtonEnabled
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 70,
                          width: MediaQuery.sizeOf(context).width - 32,
                          child: ElevatedButton(
                            onPressed: () async {
                              btnProvider.setLoading(true);
                              try {
                                await Future.delayed(
                                  const Duration(seconds: 2),
                                );

                                _analysisBottomSheet(context);
                              } catch (e) {
                              } finally {
                                btnProvider.setLoading(false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.purple.shade600,
                                    Colors.indigo.shade400,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: btnProvider.isLoading
                                    ? SizedBox(
                                        width: 40,
                                        height: 25,
                                        child: ThreeDotsLoading(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Ver análisis',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'roboto',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(
                                            Iconsax.magic_star,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _analysisBottomSheet(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: widget.btnProvider.isButtonEnabled
          ? Colors.grey.shade900
          : Theme.of(context).colorScheme.surface,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Draggable handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: widget.btnProvider.isButtonEnabled
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Análisis del sueño',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: widget.btnProvider.isButtonEnabled
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Divider(
                  color: widget.btnProvider.isButtonEnabled
                      ? Colors.grey.shade800
                      : Colors.grey.shade300,
                  height: 1,
                ),
                const SizedBox(height: 16),

                // Analysis content with smooth scrolling
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      widget.dream['analysis'],
                      style: TextStyle(
                        color: widget.btnProvider.isButtonEnabled
                            ? Colors.white
                            : Colors.grey.shade800,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (widget.suscription == 'free') ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade600,
                          Colors.indigo.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.shade200.withAlpha(40),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        btnProvider.setLoading(true);
                        try {
                          SubscriptionBottomSheet.show(context);
                        } catch (e) {
                        } finally {
                          btnProvider.setLoading(false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: btnProvider.isLoading
                          ? SizedBox(
                              width: 40,
                              height: 25,
                              child: ThreeDotsLoading(color: Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Iconsax.magic_star,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Análisis detallado',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.share,
                          color: widget.btnProvider.isButtonEnabled
                              ? Colors.white
                              : Colors.purple.shade600,
                        ),
                        label: Text(
                          'Compartir',
                          style: TextStyle(
                            color: widget.btnProvider.isButtonEnabled
                                ? Colors.white
                                : Colors.purple.shade600,
                          ),
                        ),
                        onPressed: () => null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: widget.btnProvider.isButtonEnabled
                                ? Colors.grey.shade700
                                : Colors.purple.shade400,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.btnProvider.isButtonEnabled
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Califica tu análisis',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.btnProvider.isButtonEnabled
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: RatingBar(
                                size: 28,
                                filledIcon: Icons.star_rounded,
                                emptyIcon: Icons.star_border_rounded,
                                filledColor: Colors.amber.shade400,
                                emptyColor: widget.btnProvider.isButtonEnabled
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade400,
                                onRatingChanged: (value) async {
                                  setState(() => currentRating = value);
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(
                                          FirebaseAuth
                                              .instance
                                              .currentUser
                                              ?.uid,
                                        )
                                        .collection('dreams')
                                        .doc(widget.dream.id)
                                        .update({'rating': value});
                                  } catch (e) {}
                                },
                                initialRating: currentRating,
                                maxRating: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
