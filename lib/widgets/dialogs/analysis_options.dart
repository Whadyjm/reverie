import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reverie/provider/button_provider.dart';

class AnalysisOptions {
  void showAnalysisOptionsDialog(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final isDarkMode = btnProvider.isButtonEnabled;
    final textColor = isDarkMode ? Colors.white : Colors.grey.shade900;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✨ Métodos de análisis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el enfoque que mejor se adapte a tus necesidades',
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnalysisCard(
                    context,
                    icon: '🧬',
                    title: 'Exploración Científica',
                    description:
                        'Observa tu sueño a través de la neurociencia. Explora cómo las emociones, recuerdos y experiencias se entrelazan mientras duermes.',
                    idealFor:
                        'Autoconocimiento basado en la ciencia, patrones de sueño y bienestar mental.',
                    styles:
                        'Análisis neurocognitivo, patrones REM, interpretación basada en contexto de vida.',
                    buttonText: 'Interpretación Científica',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                      _showPsychologicalSchools(context);
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildAnalysisCard(
                    context,
                    icon: '🧠',
                    title: 'Exploración Psicológica',
                    description:
                        'Conecta tu sueño con emociones, partes de ti mismo y símbolos internos.',
                    idealFor:
                        'Comprensión personal, crecimiento interior, análisis emocional',
                    styles: 'Introspectivo, simbólico, terapéutico',
                    buttonText: 'Interpretación Psicológica',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                      _showPsychologicalSchools(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildAnalysisCard(
                    context,
                    icon: '🔮',
                    title: 'Exploración Mística',
                    description:
                        'Descubre si tu sueño trae un mensaje del alma, una señal del universo o una energía especial.',
                    idealFor:
                        'Guía espiritual, significados ocultos, sincronías',
                    styles:
                        'Simbolología ancestral, tarot, energías, astrología',
                    buttonText: 'Interpretación Mística',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Hybrid Option
                  _buildAnalysisCard(
                    context,
                    icon: '🌀',
                    title: 'Ambas cosas (Híbrido)',
                    description:
                        '¿Y si los sueños fueran espejo de tu interior y mensajeros del universo? Combina ambos enfoques para una visión más completa.',
                    buttonText: 'Exploración Completa',
                    textColor: textColor,
                    cardColor: cardColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    showDetails: false,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    String? idealFor,
    String? styles,
    required String buttonText,
    required Color textColor,
    required Color cardColor,
    required VoidCallback onPressed,
    bool showDetails = true,
  }) {
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
            ),
            if (idealFor != null) ...[
              const SizedBox(height: 8),
              Text(
                'Ideal para:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                idealFor,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
            if (styles != null) ...[
              const SizedBox(height: 8),
              Text(
                'Estilos:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                styles,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPsychologicalSchools(BuildContext context) {
    final btnProvider = Provider.of<ButtonProvider>(context, listen: false);
    final isDarkMode = btnProvider.isButtonEnabled;
    final textColor = isDarkMode ? Colors.white : Colors.grey.shade900;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
            title: Text(
              'Escuelas Psicológicas',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Freudiano', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Junguiano', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: Text('Gestalt', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
