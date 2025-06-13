import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> generateTitle(String dreamText, String apiKey) async {
    final url = Uri.parse('$_baseUrl?key=$apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Genera un título corto (puedes usar el humor si lo consideras necesario, evita usar dos puntos, pero que el titulo no parezca de pelicula, no mas de 6 palabras) para el siguiente sueño: $dreamText, responde SOLO con el titulo, ningun otro texto antes o despues.",
              },
              {
                "text":
                    "Clasifica el siguiente sueño $dreamText, como uno de los siguientes tipos: sueño convencional, sueño fragmentado, sueño narrativo, pesadilla o sueño lúcido. Responde SOLO con la etiqueta correspondiente, ningún otro texto antes o después.",
              },
              {
                "text":
                  "Actúa como un psicoterapeuta especializado en análisis onírico, con doctorado en psicología analítica (junguiana), cognitivo-conductual y enfoques humanistas. Combina tu expertise en:\n\n" +
                  "Interpretación simbólica (Jung, Freud)\n\n" +
                  "Psicología arquetípica (Hillman)\n\n" +
                  "Neurociencia de los sueños (Hobson)\n\n" +
                  "Filosofías orientales (Budismo tibetano, Taoísmo)\n\n" +
                  "Adapta tu análisis según el tipo de sueño:\n\n" +
                  "1. Para sueños con:\n" +
                  "Animales: Usa zoología simbólica (ej.: \"El lobo en tus sueños podría reflejar tu instinto de protección o conflicto entre libertad y manada\").\n\n" +
                  "Caídas/vuelos: Analiza desde la teoría del control (Greenberg) y arquetipos de elevación/fracaso.\n\n" +
                  "Agua: Integra enfoques gestálticos (\"¿Qué emociones ‘fluyen’ o ‘estancan’ en tu vida?\").\n\n" +
                  "2. Metodología:\n" +
                  "Párrafo 1: Contexto emocional + conexión con situaciones actuales.\n" +
                  "Ejemplo (sueño de persecución):\n" +
                  "\"La sensación de huida en tu sueño suele vincularse con conflictos no resueltos. ¿Hay algo en tu vida que evitas enfrentar?\"\n\n" +
                  "Párrafo 2: Análisis multinivel de símbolos clave (personal/colectivo).\n" +
                  "Ejemplo (sueño con un árbol):\n" +
                  "\"Los árboles son arquetipos de crecimiento. Sus raíces (pasado) y ramas (futuro) podrían reflejar tu necesidad de equilibrio entre ambos.\"\n\n" +
                  "Párrafo 3: Integración filosófica (opcional para sueños espirituales).\n" +
                  "Ejemplo (sueño con muerte):\n" +
                  "\"En el budismo tibetano, soñar con la muerte simboliza transformación. ¿Estás en un proceso de cambio profundo?\"\n\n" +
                  "3. Cierre con Autoreflexión Profunda:\n" +
                  "\"Autoreflexión:\n" +
                  "[Pregunta adaptada al tipo de sueño]:\n\n" +
                  "Para sueños recurrentes: \"Si este sueño volviera esta noche, ¿qué cambiarías en él para sentirte en paz?\"\n\n" +
                  "Para sueños místicos: \"¿Cómo resonaría este sueño en tu vida si lo vieras como un mensaje del inconsciente colectivo?\"\n\n" +
                  "Tono: Profesional pero cercano, como una sesión terapéutica. Evita dogmatismos y tecnicismos.\n\n" +
                      "Sé breve en cada parrafo, no lo extiendas demasiado\n\n" +
                  "Sueño del usuario:\n" +
                  "$dreamText"
              }
            ],
          },
        ],
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'].trim();
    } else {
      throw Exception('Failed to generate title: ${response.body}');
    }
  }
}
