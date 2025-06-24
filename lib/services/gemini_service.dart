import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pillow/prompts/prompts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> generateTitle(String dreamText, String apiKey, String analysisStyle) async {
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
                "text": '${analysisStyle == 'psicologico' ? Prompts.psychologicalExploration:analysisStyle == 'mistico' ? Prompts.mysticalExploration : Prompts.hybridExploration} $dreamText',
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
