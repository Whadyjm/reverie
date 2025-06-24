import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pillow/widgets/orbe_loading.dart';
import 'package:provider/provider.dart';
import '../provider/button_provider.dart';
import '../style/text_style.dart';
import '../widgets/dream_bottom_sheet.dart';
import '../widgets/dream_list_empty.dart';
import '../widgets/favorite_dream_card.dart' as FavoriteDreamCard;

class FavoriteDreamsScreen extends StatelessWidget {
  const FavoriteDreamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final btnProvider = Provider.of<ButtonProvider>(context);

    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1A003F),
        Color(0xFF2E1A5E),
        Color(0xFF4A3A7C),
        Color(0xFF6B5A9A),
        Color(0xFF8C53D6),
        Color(0xFFAD75F4),
      ],
      stops: const [0.0, 0.2, 0.4, 0.5, 0.8, 1.0],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(decoration: BoxDecoration(gradient: backgroundGradient)),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.3,
            child: CustomPaint(painter: _StarsPainter()),
          ),
          Column(
            children: [
              AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade900.withOpacity(0.8),
                        Colors.purple.shade800.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Iconsax.arrow_left_2_copy, color: Colors.white),
                ),
                title: Text(
                  '✨ Favoritos',
                  style: RobotoTextStyle.titleStyle(Colors.white),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
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

                    return dreams.isEmpty
                        ? AnimatedFloatingOrbe()
                        : ListView.builder(
                          itemCount: dreams.length,
                          itemBuilder: (context, index) {
                            final dream = dreams[index];
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DreamBottomSheet(
                                      btnProvider: btnProvider,
                                      dream: dream,
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: FavoriteDreamCard.FavoriteDreamCard(
                                  btnProvider: btnProvider,
                                  dream: dream,
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

// Custom painter for stars
class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent star placement

    // Draw 100 random stars
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          random.nextDouble() * size.height * 0.8; // Keep stars in top 80%
      final radius =
          random.nextDouble() * 1.5 + 0.5; // Random size between 0.5-2.0
      final opacity =
          random.nextDouble() * 0.5 + 0.5; // Random opacity between 0.5-1.0

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withOpacity(opacity),
      );

      // Add twinkling effect to some stars
      if (random.nextDouble() > 0.7) {
        canvas.drawCircle(
          Offset(x, y),
          radius * 1.5,
          paint..color = Colors.white.withOpacity(opacity * 0.3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
