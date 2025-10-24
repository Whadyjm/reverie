import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reverie/model/user_model.dart';
import 'package:reverie/provider/button_provider.dart';
import 'package:reverie/provider/user_provider.dart';
import 'package:reverie/services/auth_service.dart';
import 'package:reverie/style/text_style.dart';
import 'package:reverie/widgets/select_gender_dialog.dart';
import 'package:reverie/widgets/threedotsloading.dart';

class DrawerHeadWidget extends StatefulWidget {
  const DrawerHeadWidget({super.key, this.dreamCount, this.dontShowAgain});

  final int? dreamCount;
  final bool? dontShowAgain;

  @override
  State<DrawerHeadWidget> createState() => _DrawerHeadWidgetState();
}

class _DrawerHeadWidgetState extends State<DrawerHeadWidget> {
  @override
  void initState() {
    super.initState();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      Provider.of<UserProvider>(
        context,
        listen: false,
      ).listenUser(firebaseUser.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final firebaseUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<UserModel?>(
      stream:
          firebaseUser != null
              ? userProvider.listenUser(firebaseUser.uid)
              : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingState();
        }
        final user = snapshot.data!;

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF311B92),
                  Color(0xFF512DA8),
                  Color(0xFF4A148C),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<User?>(
                      stream: AuthService().userChanges,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child:
                                snapshot.data?.photoURL != null
                                    ? Image.network(
                                      height: 80,
                                      snapshot.data!.photoURL!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                          size: 20,
                                        );
                                      },
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        );
                                      },
                                    )
                                    : CircleAvatar(
                                      radius: 40,
                                      backgroundColor:
                                          btnProvider.isButtonEnabled
                                              ? Colors.white.withOpacity(0.2)
                                              : Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ),
                          );
                        } else {
                          return CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                btnProvider.isButtonEnabled
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.shade200,
                            child: Icon(Icons.person, color: Colors.grey),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.dreamCount != null && widget.dreamCount! > 0
                            ? '🌙 ${widget.dreamCount} Sueños'
                            : '',
                        style: RobotoTextStyle.small3TextStyle(Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      user.name,
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
                              selectedGender: user.selectedGender,
                              dontShowAgain: widget.dontShowAgain ?? false,
                            );
                          },
                        );
                      },
                      child: Icon(
                        user.selectedGender == 'male'
                            ? Icons.male_rounded
                            : user.selectedGender == 'female'
                            ? Icons.female_rounded
                            : user.selectedGender == 'other'
                            ? Icons.transgender_rounded
                            : Icons.question_mark_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _loadingState() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF311B92), Color(0xFF512DA8), Color(0xFF4A148C)],
          ),
        ),
        child: Center(child: ThreeDotsLoading(color: Colors.white)),
      ),
    );
  }
}
