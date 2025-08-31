import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reverie/provider/button_provider.dart';
import 'package:reverie/screens/home_screen.dart';
import 'package:reverie/style/text_style.dart';
import 'package:reverie/widgets/select_gender_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class DrawerHeadWidget extends StatefulWidget {
  DrawerHeadWidget({
    super.key,
    required this.user,
    this.userName,
    required this.dreamCount,
    this.userEmail,
    required this.name,
    required this.selectedGender,
    required this.btnProvider,
    required this.dontShowAgain,
  });

  final Stream<User?> user;
  final String? userEmail;
  final String? userName;
  final int? dreamCount;
  final String name;
  late String selectedGender;
  final ButtonProvider btnProvider;
  late bool dontShowAgain;

  @override
  State<DrawerHeadWidget> createState() => _DrawerHeadWidgetState();
}

class _DrawerHeadWidgetState extends State<DrawerHeadWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF311B92), Color(0xFF512DA8), Color(0xFF4A148C)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      widget.btnProvider.isButtonEnabled
                          ? Colors.white.withAlpha(20)
                          : Colors.grey.shade200,
                  child: StreamBuilder<User?>(
                    stream: widget.user,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return UserAvatarDrawer(snapshot: snapshot);
                      } else {
                        return CircleAvatar(
                          backgroundColor:
                              widget.btnProvider.isButtonEnabled
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade200,
                          child: Icon(Icons.person, color: Colors.grey),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.dreamCount == 0
                        ? ''
                        : '🌙 ${widget.dreamCount} Sueños',
                    style: RobotoTextStyle.small2TextStyle(Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  widget.userName ?? widget.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return SelectGenderDialog(
                          selectedGender: widget.selectedGender,
                          dontShowAgain: widget.dontShowAgain,
                        );
                      },
                    );
                  },
                  child: Icon(
                    widget.selectedGender == 'male'
                        ? Icons.male_rounded
                        : widget.selectedGender == 'female'
                        ? Icons.female_rounded
                        : widget.selectedGender == 'other'
                        ? Icons.transgender_rounded
                        : Icons.question_mark_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              widget.userEmail ?? 'Email',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
