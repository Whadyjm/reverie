import 'package:flutter/material.dart';

class EmotionalEvolutionBar extends StatefulWidget {
  const EmotionalEvolutionBar({super.key});

  @override
  State<EmotionalEvolutionBar> createState() => _EmotionalEvolutionBarState();
}

class _EmotionalEvolutionBarState extends State<EmotionalEvolutionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> emotionalColors = [
    Colors.blueAccent, // tranquilidad
    Colors.deepPurple, // introspección
    Colors.redAccent, // pasión
    Colors.amberAccent, // alegría
    Colors.tealAccent, // serenidad
    Colors.pinkAccent, // amor
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(double progress, int index) {
    final total = emotionalColors.length;
    final currentIndex = (progress * total).floor() % total;
    final nextIndex = (currentIndex + 1) % total;
    final t = (progress * total) % 1;
    return Color.lerp(
      emotionalColors[currentIndex],
      emotionalColors[nextIndex],
      t,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final shift = (_animation.value + i * 0.2) % 1;
              final color = _getColor(shift, i);
              final scale = 1 + 0.3 * (1 - (shift - 0.5).abs() * 2); // pulso

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.9),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
