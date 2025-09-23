import 'dart:math';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reverie/screens/login_screen.dart';
import 'package:reverie/style/text_style.dart';
import 'package:reverie/widgets/emotional_evolution.dart';
import 'package:reverie/widgets/pulsing_container.dart';
import 'package:reverie/widgets/ripple_animation.dart';
import 'package:reverie/widgets/ripple_painter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;
  late final AnimationController _animationController;

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Registra tus sueños',
      'subtitle': 'Escribe tus sueños antes de que desaparezcan.',
    },
    {
      'title': 'Interprétalos con IA',
      'subtitle': 'Descubre el significado oculto detrás de tus sueños.',
    },
    {
      'title': 'Explora tu mundo interior',
      'subtitle': 'Observa tu evolución emocional a través de tus sueños.',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildVisual(int index) {
    switch (index) {
      case 0:
        // Página 1: Simulación de chat
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chatBubble(
              "🌙 Anoche soñé que flotaba en un mar de estrellas...",
              isUser: true,
            ),
            const SizedBox(height: 12),
            _chatBubble(
              "✨ Qué bello sueño. ¿Sientes que fue una experiencia liberadora?",
              isUser: false,
            ),
            const SizedBox(height: 20),
          ],
        );

      case 1:
        // Página 2: Análisis de IA
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PulsingContainer(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "🧠 Análisis IA:",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "• Emociones detectadas: libertad, asombro",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "• Símbolos: estrellas, vuelo, agua",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "• Interpretación: deseo de escapar de lo cotidiano...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        );

      case 2:
        // Página 3: Visual abstracto de exploración interior
        return Column(
          children: [
            SizedBox(height: 100, child: RippleAnimation()),
            const SizedBox(height: 50),
            EmotionalEvolutionBar(),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _chatBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color:
              isUser
                  ? Colors.white24
                  : Colors.deepPurple.shade600.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D0D1A),
                  Color(0xFF1B0033),
                  Color(0xFF2B0A45),
                  Color(0xFF3A0CA3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Estrellas animadas
                ...List.generate(40, (index) {
                  final random = Random(index);
                  final top =
                      random.nextDouble() * MediaQuery.of(context).size.height;
                  final left =
                      random.nextDouble() * MediaQuery.of(context).size.width;
                  final size = random.nextDouble() * 2 + 1;

                  return Positioned(
                    top: top,
                    left: left,
                    child: Opacity(
                      opacity:
                          0.5 +
                          0.5 *
                              sin(_animationController.value * 2 * pi + index),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Reverie',
                          style: AppTextStyle.biggerTitleStyle(Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: PageView.builder(
                          controller: _controller,
                          onPageChanged:
                              (index) => setState(() => _currentPage = index),
                          itemCount: onboardingData.length,
                          itemBuilder:
                              (context, index) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildVisual(index),
                                    const SizedBox(height: 24),
                                    Text(
                                      onboardingData[index]['title']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      onboardingData[index]['subtitle']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.white70,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  _currentPage == index
                                      ? Colors.white
                                      : Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: ScaleTransition(
                          scale: Tween(begin: 1.0, end: 1.05).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: GestureDetector(
                            onTap: _nextPage,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF9575CD),
                                    Color(0xFF7E57C2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1B0033,
                                    ).withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _currentPage == onboardingData.length - 1
                                      ? 'Comenzar'
                                      : 'Siguiente',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
