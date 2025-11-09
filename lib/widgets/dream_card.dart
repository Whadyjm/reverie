import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:reverie/widgets/analysis_style_tag.dart';
import '../provider/button_provider.dart';
import '../style/text_style.dart';
import 'like_button.dart';

class DreamCard extends StatefulWidget {
  DreamCard({
    super.key,
    required this.btnProvider,
    required this.dream,
    required this.isLongPress,
  });

  bool isLongPress;
  final ButtonProvider btnProvider;
  final QueryDocumentSnapshot<Object?> dream;

  @override
  State<DreamCard> createState() => _DreamCardState();
}

class _DreamCardState extends State<DreamCard> {
  @override
  Widget build(BuildContext context) {
    final analysisStyle = widget.dream['analysisStyle'];
    final btnProvider = Provider.of<ButtonProvider>(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 10.0, bottom: 12.0),
      child: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(
              minWidth: 200,
              maxWidth: 350,
              minHeight: 80,
              maxHeight: 500,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Blur(
                        colorOpacity: 0,
                        blur: btnProvider.isTextBlurred ? 2.5 : 0,
                        child: Text(
                          widget.dream['title'],
                          style: AppTextStyle.subtitleStyle(
                            Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Blur(
                    colorOpacity: 0,
                    blur: btnProvider.isTextBlurred ? 2.5 : 0,
                    child: Text(
                      widget.dream['text'],
                      maxLines: 8,
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
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnalysisStyleTag(analysisStyle: analysisStyle),
                    const SizedBox(width: 20),
                    LikeButton(
                      isLiked: widget.dream['isLiked'],
                      dreamId: widget.dream['dreamId'],
                    ),
                    const SizedBox(width: 20),
                    Chip(
                      label: Blur(
                        borderRadius: BorderRadius.circular(12),
                        colorOpacity: 0.01,
                        blur: btnProvider.isTextBlurred ? 2.5 : 0,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            widget.dream['classification'],
                            style: LexendTextStyle.small2TextStyle(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      backgroundColor:
                          widget.dream['classification'] == 'Pesadilla'
                              ? Colors.purple.shade700
                              : Colors.purple.shade400,
                      avatar: Icon(
                        widget.dream['classification'] == 'Pesadilla'
                            ? Iconsax.emoji_sad
                            : Iconsax.happyemoji,
                        color: Colors.white,
                        size: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.isLongPress)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () async {
                  await firestore
                      .collection('users')
                      .doc(auth.currentUser?.uid)
                      .collection('dreams')
                      .doc(widget.dream['dreamId'])
                      .delete();
                  print('Dream deleted');
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 4, right: 4),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade600,
                        blurRadius: 4,
                        offset: Offset(2, 1),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.remove_rounded,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
