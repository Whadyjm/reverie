import 'dart:ui';
import 'package:flutter/material.dart';
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
  const _BottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, controller) => SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                    gradientColors: [Colors.deepPurple.shade800, Colors.deepPurple.shade600],
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
                      "Sin Ads"
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPlanCard(
                    context,
                    title: "Plus",
                    price: "\$2.99/mes · \$14.99/año",
                    gradientColors: [Colors.indigo.shade800, Colors.indigo.shade600],
                    textColor: Colors.white,
                    buttonColor: Colors.indigoAccent.shade200,
                    buttonText: "Prueba 7 días",
                    features: const [
                      "Registro ilimitado",
                      "Análisis avanzado",
                      "Estadísticas detalladas",
                      "Etiquetas simples",
                      "Backup en la nube",
                      "Sin Ads"
                    ],
                    isRecommended: true,
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 40),
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
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "⭐ Recomendado",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(title.toUpperCase(), style: RobotoTextStyle.titleStyle(textColor)),
                const SizedBox(height: 10),
                Text(price, style: RobotoTextStyle.subtitleStyle(Colors.grey.shade300)),
                const SizedBox(height: 20),
                ..._buildFeatureList(features),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Seleccionaste: $title")),
                      );
                    },
                    child: Text(buttonText, style: RobotoTextStyle.smallTextStyle(Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features
        .map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _feature(feature),
    ))
        .toList();
  }

  Widget _feature(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.star_rounded, size: 18, color: Colors.indigoAccent),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: RobotoTextStyle.small2TextStyle(Colors.white70),
          ),
        ),
      ],
    );
  }
}
