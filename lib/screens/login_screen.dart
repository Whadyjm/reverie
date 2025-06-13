import 'package:flutter/material.dart';
import 'dart:math';

import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final Color primaryPurple = const Color(0xFF9C6BFF);
  final Color secondaryPurple = const Color(0xFF7F5AFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B3D82),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryPurple.withOpacity(0.4),
                  secondaryPurple.withOpacity(0.4),
                  const Color(
                    0xFF6A4C93,
                  ).withOpacity(0.4),
                  const Color(
                    0xFF3E2C70,
                  ).withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/pillow_icon.png', height: 200),
                  const SizedBox(height: 20),
                  Text(
                    'Pillow',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          Positioned.fill(child: AnimatedBackground()),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 550),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    // Handle sign up
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.transparent),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Regístrate',
                    style: TextStyle(
                      fontSize: 18,
                      color: primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Crear 15 partículas con posiciones y velocidades aleatorias
    for (int i = 0; i < 15; i++) {
      _particles.add(
        Particle(
          Random().nextDouble(),
          Random().nextDouble(),
          Random().nextDouble() * 2 + 1,
          Random().nextDouble() * 0.5 + 0.5,
        ),
      );
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particles, _controller.value),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double size;
  double angle;

  Particle(this.x, this.y, this.speed, this.size)
    : angle = Random().nextDouble() * 2 * pi;

  void move(double time) {
    // Movimiento circular suave
    angle += speed * 0.002;
    x = x + cos(angle) * 0.002;
    y = y + sin(angle) * 0.002;

    // Mantener las partículas dentro de los límites
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..blendMode = BlendMode.overlay;

    for (var particle in particles) {
      particle.move(time);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size * 3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
