import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pillow/screens/login_screen.dart';
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
      'image': 'assets/page1.png',
    },
    {
      'title': 'Interprétalos con IA',
      'subtitle': 'Descubre el significado oculto detrás de tus sueños.',
      'image': 'assets/page2.png',
    },
    {
      'title': 'Explora tu mundo interior',
      'subtitle': 'Observa tu evolución emocional a través de tus sueños.',
      'image': 'assets/page3.png',
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
                  Color(0xFF311B92), // Dark Indigo
                  Color(0xFF512DA8), // Dark Purple
                  Color(0xFF4A148C), // Deeper Purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Estrellas animadas
                ...List.generate(40, (index) {
                  final random = Random(index);
                  final top = random.nextDouble() * MediaQuery.of(context).size.height;
                  final left = random.nextDouble() * MediaQuery.of(context).size.width;
                  final size = random.nextDouble() * 2 + 1;

                  return Positioned(
                    top: top,
                    left: left,
                    child: Opacity(
                      opacity: 0.5 +
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

                // Contenido principal
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _controller,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemCount: onboardingData.length,
                          itemBuilder: (context, index) => Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),
                                Expanded(
                                  child: Image.asset(
                                    onboardingData[index]['image']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  onboardingData[index]['title']!,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  onboardingData[index]['subtitle']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
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
                              color: _currentPage == index
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
                        child: GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7E57C2),
                                  Color(0xFF9575CD),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _currentPage == onboardingData.length - 1
                                    ? 'Comenzar'
                                    : 'Siguiente',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
