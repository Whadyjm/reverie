import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static final Set<String> _usedNames = {};

  Future<String> generateName(String apiKey) async {
    try {
      String newName;
      do {
        final response = await http.post(
          Uri.parse('$_baseUrl?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {
                    "text":
                    "Genera exactamente una sola palabra (no utilices palabras"
                        " o terminos usados en el padel, puedes agregar algo de humor, puede ser en ingles o español,"
                        " puede estar relacionado con lo que sea, animales por ejemplo,"
                        " sin comillas, puntos o cualquier otro caracter adicional) que"
                        " será el nombre de un equipo de pádel. La palabra debe tener máximo"
                        " 15 caracteres, ser única (no repetirse) y creativa. Responde SÓLO"
                        " con la palabra, sin ningún texto antes o después.",
                  },
                ],
              },
            ],
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          newName = data['candidates'][0]['content']['parts'][0]['text'].trim();

          // Verificación adicional por si el modelo no siguió las instrucciones
          if (newName.contains(' ') || newName.length > 15) {
            throw Exception('El nombre generado no cumple los requisitos');
          }
        } else {
          throw Exception('Error, intente nuevamente en unos minutos');
        }
      } while (_usedNames.contains(
        newName,
      )); // Reintenta si el nombre ya fue usado

      // Agrega el nuevo nombre al conjunto de nombres usados
      _usedNames.add(newName);

      return newName;
    } catch (e) {
      throw Exception('Error, intente nuevamente en unos minutos');
    }
  }
  }