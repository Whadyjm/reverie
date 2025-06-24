import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedFloatingOrbe extends StatefulWidget {
  final double size;
  final Color color;

  const AnimatedFloatingOrbe({
    super.key,
    this.size = 25,
    this.color = Colors.white38,
  });

  @override
  State<AnimatedFloatingOrbe> createState() => _AnimatedFloatingOrbeState();
}

class _AnimatedFloatingOrbeState extends State<AnimatedFloatingOrbe>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  late AnimationController _moveController;
  late Animation<Offset> _offsetAnimation;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();


    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Movimiento aleatorio
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _offsetAnimation = _generateRandomOffsetAnimation();
    _moveController.repeat(reverse: true);
    _moveController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _offsetAnimation = _generateRandomOffsetAnimation();
        _moveController.forward(from: 0);
      }
    });
  }

  Animation<Offset> _generateRandomOffsetAnimation() {
    // Movimiento máximo en píxeles
    final dx = (_random.nextDouble() - 0.5) * 40;
    final dy = (_random.nextDouble() - 0.5) * 40;
    return Tween<Offset>(
      begin: Offset.zero,
      end: Offset(dx, dy),
    ).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _moveController]),
      builder: (context, child) {
        return Transform.translate(
          offset: _offsetAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.85),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
