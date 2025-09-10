import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:reverie/style/text_style.dart';

class SubscriptionBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SubscriptionPaywall(),
    );
  }
}

class _SubscriptionPaywall extends StatelessWidget {
  const _SubscriptionPaywall();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.8,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              _PaywallBackground(),
              _PaywallContent(scrollController: scrollController),
            ],
          ),
        );
      },
    );
  }
}

class _PaywallBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Stack(
        children: [
          Image.asset(
            'assets/paywall.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.6),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.2, 0.5, 1.0],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallContent extends StatelessWidget {
  final ScrollController scrollController;

  const _PaywallContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PaywallHeader(),
          const SizedBox(height: 16),
          _SubscriptionPlanList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PaywallHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          height: 5,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Elige tu plan de suscripción",
          style: AppTextStyle.titleStyle(Colors.white).copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Desbloquea contenido exclusivo y disfruta de una experiencia sin límites.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _SubscriptionPlanList extends StatefulWidget {
  @override
  State<_SubscriptionPlanList> createState() => _SubscriptionPlanListState();
}

class _SubscriptionPlanListState extends State<_SubscriptionPlanList> {
  int? _selectedIndex;

  final plans = [
    {
      'title': 'BÁSICO',
      'price': '\$1.99 / mes',
      'gradientColors': [Colors.blue.shade800, Colors.blue.shade600],
      'textColor': Colors.white,
      'buttonColor': Colors.blue.shade700,
      'buttonText': 'Elegir Plan Básico',
      'features': [
        'Registro ilimitado de sueños.',
        'Reporte de emociones.',
        'Sin anuncios.',
      ],
      'isRecommended': false,
    },
    {
      'title': 'PRO',
      'price': '\$3.99 / mes',
      'gradientColors': [Colors.deepPurple.shade800, Colors.purple.shade600],
      'textColor': Colors.white,
      'buttonColor': Colors.deepPurple.shade700,
      'buttonText': 'Elegir Plan Pro',
      'features': [
        'Todo lo del plan Básico.',
        'Backup en la nube.',
        'Análisis científico.',
        'Comparte tus análisis y sueños.',
      ],
      'isRecommended': true,
    },
    {
      'title': 'ANUAL',
      'price': '\$29.99 / año',
      'gradientColors': [Colors.green.shade800, Colors.green.shade600],
      'textColor': Colors.white,
      'buttonColor': Colors.green.shade700,
      'buttonText': 'Elegir Plan Anual',
      'features': [
        'Todo lo del plan Pro.',
        'Ahorra un 35%.',
        'Acceso a gráficos de tus emociones.',
      ],
      'isRecommended': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(plans.length, (index) {
          final plan = plans[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeIn,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border:
                    isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
              ),
              child: _buildPlanCard(
                context,
                title: plan['title'] as String,
                price: plan['price'] as String,
                gradientColors: plan['gradientColors'] as List<Color>,
                textColor: plan['textColor'] as Color,
                buttonColor: plan['buttonColor'] as Color,
                buttonText: plan['buttonText'] as String,
                features: plan['features'] as List<String>,
                isRecommended: plan['isRecommended'] as bool,
                isSelected: isSelected,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required List<Color> gradientColors,
    required Color textColor,
    required Color buttonColor,
    required String buttonText,
    required List<String> features,
    bool isRecommended = false,
    required bool isSelected,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradientColors.first.withOpacity(0.6),
                    gradientColors.last.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        title.toLowerCase().contains('pro')
                            ? Iconsax.star_1_copy
                            : title.toLowerCase().contains('anual')
                            ? Iconsax.calendar_1_copy
                            : Iconsax.crown_copy,
                        color: textColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              price,
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...features
                      .asMap()
                      .entries
                      .map(
                        (entry) => _PaywallFeature(
                          text: entry.value,
                          delay: entry.key * 70,
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 20),
                  if (isSelected)
                    _ActionButton(
                      buttonColor: buttonColor,
                      buttonText: buttonText,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (isRecommended)
          Positioned(
            top: -10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.star_rounded, color: Colors.black, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "Más popular",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PaywallFeature extends StatelessWidget {
  final String text;
  final int delay;

  const _PaywallFeature({required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Colors.lightGreen,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final Color buttonColor;
  final String buttonText;

  const _ActionButton({required this.buttonColor, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(36),
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              buttonColor.withOpacity(0.95),
              buttonColor.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withAlpha(80),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
