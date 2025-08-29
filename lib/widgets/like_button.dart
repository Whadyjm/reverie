import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/dream_provider.dart';

class LikeButton extends StatefulWidget {
  LikeButton({super.key, required this.isLiked, required this.dreamId});

  bool isLiked;
  String dreamId;
  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final can = await Haptics.canVibrate();

        if (!can) {
          return;
        }
        await Haptics.vibrate(HapticsType.success);
        setState(() {
          liked = !liked;
        });
        try {
          var dreamsCollection = firestore
              .collection('users')
              .doc(auth.currentUser?.uid)
              .collection('dreams');

          var documentSnapshot =
              await firestore
                  .collection('users')
                  .doc(auth.currentUser?.uid)
                  .collection('dreams')
                  .doc(widget.dreamId)
                  .get();
          bool liked = documentSnapshot.data()?['isLiked'] ?? false;

          if (widget.dreamId == null) {
            throw Exception('No document found to update.');
          }

          await dreamsCollection.doc(widget.dreamId).update({
            'isLiked': liked ? false : true, // Update the field as needed
          });
        } catch (e) {}
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(1, 2),
              spreadRadius: 2,
              blurRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: Icon(
            widget.isLiked ? Iconsax.heart : Iconsax.heart_copy,
            key: ValueKey<bool>(liked),
            color: Colors.indigo,
          ),
        ),
      ),
    );
  }
}
