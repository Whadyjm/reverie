import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmotionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<String>> _getDreamsFromLast30Days(String userId) async {
    final now = DateTime.now();
    final lastMonth = now.subtract(const Duration(days: 30));

    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('dreams')
            .where('timestamp', isGreaterThan: lastMonth)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs
        .map((doc) => doc.data()['text'] as String? ?? "")
        .where((dream) => dream.isNotEmpty)
        .toList();
  }

  String _buildPrompt(List<String> dreams) {
    final joined = dreams.join("\n---\n");
    return '''
Tengo una lista de sueños escritos por un usuario en los últimos 30 días. Analízalos y dime cuál es la emoción predominante. SOLO responde con la emoción.

Sueños:
$joined
''';
  }

  Future<String> analyzeUserEmotions(String userId, String apikey) async {
    final dreams = await _getDreamsFromLast30Days(userId);

    if (dreams.isEmpty) {
      return "No se encontraron sueños en los últimos 30 días.";
    }

    final prompt = _buildPrompt(dreams);
    final apiKey = apikey;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception("Error ${response.statusCode}: ${response.body}");
    }
  }
}
