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
       'prompt': {
         'text': 'Generate a short title (no more than 10 words) for the following: $dreamText',
       },
       'temperature': 0.7,
       'maxOutputTokens': 50,
     }),
   );

   if (response.statusCode == 200) {
     final data = jsonDecode(response.body);
     return data['candidates'][0]['output'] ?? 'No title generated';
   } else {
     throw Exception('Failed to generate title: ${response.body}');
   }
 }

  }
