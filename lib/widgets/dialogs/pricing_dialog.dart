import 'package:flutter/material.dart';

import '../../style/gradients.dart';
import '../../style/text_style.dart';

class SubscriptionBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _BottomSheetContent(),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      initialChildSize: 0.85,
      builder: (_, controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Text(
                "Elige tu plan de suscripción",
                style: RobotoTextStyle.titleStyle(Colors.white)
              ),
              const SizedBox(height: 24),
              _buildPlanCard(
                context,
                title: "Pro Visionario",
                price: "\$5.99/mes · \$29.99/año · \$49.99 vitalicio",
                gradientColors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
                textColor: Colors.deepPurple.shade900,
                buttonColor: Colors.deepPurple.shade400,
                buttonText: "Explorar Premium",
                features: const [
                  "Interpretación guiada",
                  "Sonidos y meditaciones",
                  "Análisis junguiano",
                  "Exportación PDF",
                  "Resumen mensual por correo",
                ],
              ),
              const SizedBox(height: 24),
              _buildPlanCard(
                context,
                title: "Plus",
                price: "\$2.99/mes · \$14.99/año",
                gradientColors: [Colors.indigo.shade100, Colors.indigo.shade50],
                textColor: Colors.indigo.shade900,
                buttonColor: Colors.indigo.shade700,
                buttonText: "Prueba 7 días",
                features: const [
                  "Análisis IA avanzado",
                  "Estadísticas detalladas",
                  "Backup en la nube",
                  "Personalización visual",
                  "Diario guiado",
                ],
                isRecommended: true,
              ),
              const SizedBox(height: 24),
              _buildPlanCard(
                context,
                title: "Freemium",
                price: "Gratis",
                gradientColors: [Colors.grey.shade200, Colors.grey.shade100],
                textColor: Colors.black87,
                buttonColor: Colors.black87,
                buttonText: "Comenzar",
                features: const [
                  "Registro ilimitado",
                  "Análisis IA básico",
                  "Estadísticas semanales",
                  "Etiquetas simples",
                  "Sincronización local",
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
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
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  color: Colors.black.withOpacity(0.08),
                ),
                if (isRecommended)
                  BoxShadow(
                    blurRadius: 20,
                    color: buttonColor.withOpacity(0.3),
                    spreadRadius: 2,
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
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Recomendado",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  title.toUpperCase(),
                  style: RobotoTextStyle.titleStyle(textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: RobotoTextStyle.subtitleStyle(textColor),
                ),
                const SizedBox(height: 20),
                _feature(features[0]),
                const SizedBox(height: 6),
                _feature(features[1]),
                const SizedBox(height: 6),
                _feature(features[2]),
                const SizedBox(height: 6),
                _feature(features[3]),
                const SizedBox(height: 6),
                _feature(features[4]),
                const SizedBox(height: 28),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Seleccionaste: $title")),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Text(
                        buttonText,
                        style: RobotoTextStyle.smallTextStyle(Colors.white)
                      ),
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

  Widget _feature(String text) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 20, color: Colors.indigoAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: RobotoTextStyle.small2TextStyle(Colors.black87)
          ),
        ),
      ],
    );
  }



  Widget icon() => const Icon(Icons.check_circle, size: 18, color: Colors.green);
}
