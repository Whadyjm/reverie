import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import '../provider/button_provider.dart';
import '../style/gradients.dart';
import '../style/text_style.dart';
import '../widgets/dream_bottom_sheet.dart';
import '../widgets/favorite_dream_card.dart' as FavoriteDreamCard;
import '../widgets/orbe_loading.dart';

class FavoriteDreamsScreen extends StatelessWidget {
  const FavoriteDreamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final btnProvider = Provider.of<ButtonProvider>(context);

    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: Gradients.favoriteBackground,
      stops: const [0.0, 0.2, 0.4, 0.5, 0.8, 1.0],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),

          // Stars with glow effect
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: CustomPaint(painter: _StarsPainter()),
          ),

          // Content
          Column(
            children: [
              // Cozy AppBar with frosted effect
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: AppBar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.6),
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Iconsax.arrow_left_2_copy, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    '✨ Favoritos',
                    style: RobotoTextStyle.titleStyle(Colors.white),
                  ),
                  flexibleSpace: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

              // Favorite dreams list
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      firestore
                          .collection('users')
                          .doc(auth.currentUser?.uid)
                          .collection('dreams')
                          .where('isLiked', isEqualTo: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final dreams = snapshot.data?.docs ?? [];

                    if (dreams.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedFloatingOrbe(),
                            const SizedBox(height: 16),
                            Text(
                              'Aún no hay sueños favoritos ✨',
                              style: RobotoTextStyle.subtitleStyle(
                                Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: dreams.length,
                      itemBuilder: (context, index) {
                        final dream = dreams[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => DreamBottomSheet(
                                    btnProvider: btnProvider,
                                    dream: dream,
                                  ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Material(
                              borderRadius: BorderRadius.circular(20),
                              elevation: 5,
                              shadowColor: Colors.purpleAccent.withOpacity(0.2),
                              child: FavoriteDreamCard.FavoriteDreamCard(
                                btnProvider: btnProvider,
                                dream: dream,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stars Painter with soft glow
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);

    for (int i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.8;
      final radius = random.nextDouble() * 1.5 + 0.5;
      final opacity = random.nextDouble() * 0.5 + 0.5;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);

      // Soft glow
      if (random.nextDouble() > 0.75) {
        paint.color = Colors.white.withOpacity(opacity * 0.25);
        canvas.drawCircle(Offset(x, y), radius * 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
