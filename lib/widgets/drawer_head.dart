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
                          final int dreams = widget.dreamCount ?? 0;
                          final String badgeAsset;
                          if (dreams == 0) {
                            badgeAsset = 'assets/welcomeBadge.png';
                          } else if (dreams >= 100) {
                            badgeAsset = 'assets/100Badge.png';
                          } else if (dreams >= 50) {
                            badgeAsset = 'assets/50Badge.png';
                          } else if (dreams >= 25) {
                            badgeAsset = 'assets/25Badge.png';
                          } else if (dreams >= 1) {
                            badgeAsset = 'assets/firstBadge.png';
                          } else {
                            badgeAsset = 'assets/100Badge.png';
                          }

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: ClipOval(
                                  child:
                                      snapshot.data?.photoURL != null
                                          ? Image.network(
                                            snapshot.data!.photoURL!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                          : Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color:
                                                  btnProvider.isButtonEnabled
                                                      ? Colors.white
                                                          .withOpacity(0.2)
                                                      : Colors.grey.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                ),
                              ),
                              Positioned(
                                top: -30,
                                right: -50,
                                child: Image.asset(
                                  badgeAsset,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ],
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
