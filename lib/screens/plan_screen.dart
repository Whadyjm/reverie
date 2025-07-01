import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Planes de Suscripción"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPlanCard(
              context,
              title: "Freemium",
              price: "Gratis",
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black,
              buttonColor: Colors.black,
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
            _buildPlanCard(
              context,
              title: "Plus",
              price: "\$2.99/mes · \$14.99/año",
              backgroundColor: Colors.indigo.shade50,
              textColor: Colors.indigo.shade900,
              buttonColor: Colors.indigo.shade600,
              buttonText: "Prueba 7 días",
              features: const [
                "Análisis IA avanzado",
                "Estadísticas detalladas",
                "Backup en la nube",
                "Personalización visual",
                "Diario guiado",
              ],
            ),
            const SizedBox(height: 24),
            _buildPlanCard(
              context,
              title: "Pro Visionario",
              price: "\$5.99/mes · \$29.99/año\n\$49.99 vitalicio",
              backgroundColor: Colors.deepPurple.shade50,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, {
        required String title,
        required String price,
        required Color backgroundColor,
        required Color textColor,
        required Color buttonColor,
        required String buttonText,
        required List<String> features,
      }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              )),
          const SizedBox(height: 8),
          Text(price,
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.7),
              )),
          const SizedBox(height: 20),

          // Manual features display (not a list)
          Row(children: [icon(), const SizedBox(width: 8), Text(features[0])]),
          const SizedBox(height: 6),
          Row(children: [icon(), const SizedBox(width: 8), Text(features[1])]),
          const SizedBox(height: 6),
          Row(children: [icon(), const SizedBox(width: 8), Text(features[2])]),
          const SizedBox(height: 6),
          Row(children: [icon(), const SizedBox(width: 8), Text(features[3])]),
          const SizedBox(height: 6),
          Row(children: [icon(), const SizedBox(width: 8), Text(features[4])]),

          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Seleccionaste: $title")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget icon() => const Icon(Icons.check_circle, size: 18, color: Colors.green);
}
