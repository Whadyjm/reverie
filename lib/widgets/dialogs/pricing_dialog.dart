import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../style/text_style.dart';

class SubscriptionBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _BottomSheetContent(),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withAlpha(90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder:
                (_, controller) => SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 5,
                        width: 50,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      Text(
                        "Elige tu plan de suscripción",
                        style: RobotoTextStyle.titleStyle(Colors.white),
                      ),
                      const SizedBox(height: 28),
                      _buildPlanCard(
                        context,
                        title: "Premium",
                        price: "\$4.99/mes · \$25.99/año · \$49.99 Vitalicio",
                        gradientColors: [
                          Colors.deepPurple.shade800,
                          Colors.deepPurple.shade600,
                        ],
                        textColor: Colors.white,
                        buttonColor: Colors.deepPurpleAccent.shade200,
                        buttonText: "Explorar Premium",
                        features: const [
                          "Registro ilimitado",
                          "Análisis avanzado",
                          "Estadísticas detalladas",
                          "Resumen mensual por correo",
                          "Comparte tu sueño y/o análisis",
                          "Etiquetas avanzadas",
                          "Backup en la nube",
                          "Sin Ads",
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildPlanCard(
                        context,
                        title: "Plus",
                        price: "\$2.99/mes · \$14.99/año",
                        gradientColors: [
                          Colors.indigo.shade800,
                          Colors.indigo.shade600,
                        ],
                        textColor: Colors.white,
                        buttonColor: Colors.indigoAccent.shade200,
                        buttonText: "Prueba 7 días",
                        features: const [
                          "Registro ilimitado",
                          "Análisis limitado",
                          "Estadísticas limitadas",
                          "Etiquetas simples",
                          "Backup en la nube",
                          "Sin Ads",
                        ],
                        isRecommended: true,
                      ),
                      /*const SizedBox(height: 20),
                  _buildPlanCard(
                    context,
                    title: "Freemium",
                    price: "Gratis",
                    gradientColors: [Colors.grey.shade800, Colors.grey.shade700],
                    textColor: Colors.white,
                    buttonColor: Colors.grey.shade600,
                    buttonText: "Comenzar",
                    features: const [
                      "Registro ilimitado",
                      "Análisis básico",
                      "Estadísticas mensuales",
                      "Etiquetas simples",
                    ],
                  ),
                  const SizedBox(height: 40),*/
                    ],
                  ),
                ),
          ),
        ),
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
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          // Glassmorphism effect
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColors.first.withOpacity(0.85),
                      gradientColors.last.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: buttonColor.withAlpha(60),
                      blurRadius: 32,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isRecommended)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade600,
                                ],
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
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Recomendado",
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
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          // Plan icon
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  buttonColor.withOpacity(0.7),
                                  buttonColor.withOpacity(0.95),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: buttonColor.withAlpha(80),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              title.toLowerCase().contains('premium')
                                  ? Icons.workspace_premium_rounded
                                  : Icons.star_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.toUpperCase(),
                                  style: RobotoTextStyle.titleStyle(
                                    textColor,
                                  ).copyWith(
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  price,
                                  style: RobotoTextStyle.subtitleStyle(
                                    Colors.grey.shade200,
                                  ).copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      ...features
                          .asMap()
                          .entries
                          .map(
                            (entry) => TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(
                                milliseconds: 320 + entry.key * 70,
                              ),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 10 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _feature(entry.value),
                            ),
                          )
                          .toList(),
                      const SizedBox(height: 32),
                      Center(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(36),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 38,
                              vertical: 16,
                            ),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  buttonText,
                                  style: RobotoTextStyle.smallTextStyle(
                                    Colors.white,
                                  ).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _feature(feature),
          ),
        )
        .toList();
  }

  Widget _feature(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.star_rounded, size: 18, color: Colors.amber),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: RobotoTextStyle.small2TextStyle(Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}
