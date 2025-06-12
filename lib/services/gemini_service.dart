import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  String apiKey = 'AIzaSyC8v3uePDi7tVVICufejchab2ifad0u05s';

 Future<String> generateTitle(String dreamText) async {
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
               "Genera un título corto (no mas de 10 palabras) para el siguiente sueño: $dreamText, responde SOLO con el titulo, ningun otro texto antes o despues.",
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
