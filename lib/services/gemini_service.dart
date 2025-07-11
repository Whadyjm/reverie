import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pillow/prompts/prompts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                    "(Agrega acá un icono unicode com prefijo relacionado al contenido del sueño)Genera un título corto (puedes usar el humor si lo consideras necesario, evita usar dos puntos, pero que el titulo no parezca de pelicula, no mas de 6 palabras) para el siguiente sueño: $dreamText, responde SOLO con el titulo, ningun otro texto antes o despues.",
              },
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

  Future<String> generateShortAnalysis(
    String dreamText,
    String apiKey,
    String analysisStyle,
    String selectedGender,
    String userName,
  ) async {
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
                    'Contexto:'
                    'nombre: $userName, PROHIBIDO mostrarlo en el análisis.'
                    'género: $selectedGender, PROHIBIDO mostrarlo en el análisis.'
                    '${analysisStyle == 'cientifico'
                        ? Prompts.neurocognitiveDreamAnalysis
                        : analysisStyle == 'psicologico'
                        ? Prompts.psychologicalExploration
                        : analysisStyle == 'mistico'
                        ? Prompts.mysticalExploration
                        : Prompts.hybridExploration} $dreamText'
                    'El analisis debe ser breve, no PASES de 2 párrafos.',
              },
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

  Future<String> generateAnalysis(
    String dreamText,
    String apiKey,
    String analysisStyle,
    String selectedGender,
    String userName,
    String suscription,
  ) async {
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
                    'Contexto:'
                    'nombre: $userName, PROHIBIDO mostrarlo en el análisis.'
                    'género: $selectedGender, PROHIBIDO mostrarlo en el análisis.'
                    '${analysisStyle == 'cientifico'
                        ? Prompts.neurocognitiveDreamAnalysis
                        : analysisStyle == 'psicologico'
                        ? Prompts.psychologicalExploration
                        : analysisStyle == 'mistico'
                        ? Prompts.mysticalExploration
                        : Prompts.hybridExploration} $dreamText'
                    '${suscription == 'free' ? 'analisis debe ser breve, no PASES de 2 párrafos.' : 'Haz un análisis detallado, de 4 párrafos y profundo del sueño'}',
              },
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

  Future<String> generateTag(String dreamText, String apiKey) async {
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
                    "Clasifica el siguiente sueño $dreamText, como uno de los siguientes tipos: sueño convencional, sueño fragmentado, sueño narrativo, pesadilla o sueño lúcido. Responde SOLO con la etiqueta correspondiente, ningún otro texto antes o después.",
              },
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

  Future<String> generateEmotion(String dreamText, String apiKey) async {
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
                    "$dreamText Detecta y nombra las emociones predominantes presentes en el siguiente sueño."
                    "Sé específico y directo. Solo nombra 3 palabras que representen el sueño. Responde SOLO con las palabras, ningún otro texto antes o después."
                    "Muestra cada palabra con su icono como prefijo, una al lado de la otra separadas por dos espacios"
                    "Agrega ademas un icono unicode com prefijo relacionado con cada palabra.",
              },
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
