import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String apiKey = "YOUR_OPENAI_API_KEY";

  Future<String> askAI(String message) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": message}
        ]
      }),
    );

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}