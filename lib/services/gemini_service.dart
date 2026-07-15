import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';

  String _getSystemInstruction(String level, String language) {
    return "You are an educational AI assistant. The user's learning level is $level. "
        "Adjust vocabulary, depth, and examples accordingly:\n"
        "- Kids: very simple words, fun comparisons, emoji allowed\n"
        "- School Student: clear explanations, relatable examples\n"
        "- College Student: technical accuracy, include mechanisms\n"
        "- Professional: comprehensive, include research context and applications\n"
        "Respond entirely in $language.";
  }

  /// CALL 1 - Scan Object (Vision)
  Future<Map<String, dynamic>> scanObject(
    String base64Image,
    String mimeType, {
    String level = 'School Student',
    String language = 'English',
  }) async {
    final url = Uri.parse('$_baseUrl/gemini-1.5-flash-latest:generateContent?key=$_apiKey');
    
    final payload = {
      "systemInstruction": {
        "parts": [
          {"text": _getSystemInstruction(level, language)}
        ]
      },
      "contents": [
        {
          "parts": [
            {
              "inlineData": {
                "mimeType": mimeType,
                "data": base64Image
              }
            },
            {
              "text": "Identify this object and provide educational details about it."
            }
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "OBJECT",
          "properties": {
            "object_name": {"type": "STRING"},
            "category": {"type": "STRING"},
            "description": {"type": "STRING"},
            "fun_facts": {
              "type": "ARRAY",
              "items": {"type": "STRING"}
            },
            "is_safe": {"type": "BOOLEAN"}
          },
          "required": ["object_name", "category", "description", "fun_facts", "is_safe"]
        }
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(text);
      } catch (e) {
        throw Exception('Failed to parse JSON from Gemini: $e\nResponse: ${response.body}');
      }
    } else {
      throw Exception('Failed to generate content: ${response.body}');
    }
  }

  /// CALL 2 - Generate Quiz
  Future<List<dynamic>> generateQuiz(String objectName, String description, List<String> funFacts, {String level = 'School Student', String language = 'English'}) async {
    final url = Uri.parse('$_baseUrl/gemini-1.5-flash-latest:generateContent?key=$_apiKey');
    final payload = {
      "systemInstruction": {"parts": [{"text": _getSystemInstruction(level, language)}]},
      "contents": [
        {
          "parts": [
            {"text": "Generate a 5-question multiple choice quiz about $objectName based on this info: Description: $description. Fun facts: ${funFacts.join(', ')}"}
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "ARRAY",
          "items": {
            "type": "OBJECT",
            "properties": {
              "question": {"type": "STRING"},
              "options": {"type": "ARRAY", "items": {"type": "STRING"}},
              "correct_index": {"type": "INTEGER"},
              "explanation": {"type": "STRING"}
            },
            "required": ["question", "options", "correct_index", "explanation"]
          }
        }
      }
    };

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      final text = jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(text);
    }
    throw Exception('Failed to generate quiz');
  }

  /// CALL 3 - Object Timeline
  Future<List<dynamic>> generateTimeline(String objectName, {String level = 'School Student', String language = 'English'}) async {
    final url = Uri.parse('$_baseUrl/gemini-1.5-pro-latest:generateContent?key=$_apiKey');
    final payload = {
      "systemInstruction": {"parts": [{"text": _getSystemInstruction(level, language)}]},
      "contents": [
        {"parts": [{"text": "Generate a chronological historical timeline for $objectName (5-8 entries)."}]}
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "ARRAY",
          "items": {
            "type": "OBJECT",
            "properties": {
              "year": {"type": "STRING"},
              "event": {"type": "STRING"}
            },
            "required": ["year", "event"]
          }
        }
      }
    };

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      final text = jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(text);
    }
    throw Exception('Failed to generate timeline');
  }

  /// CALL 4 - AI Compare
  Future<Map<String, dynamic>> compareObjects(String objectA, String objectB, {String level = 'School Student', String language = 'English'}) async {
    final url = Uri.parse('$_baseUrl/gemini-1.5-pro-latest:generateContent?key=$_apiKey');
    final payload = {
      "systemInstruction": {"parts": [{"text": _getSystemInstruction(level, language)}]},
      "contents": [
        {"parts": [{"text": "Compare $objectA and $objectB in detail."}]}
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "OBJECT",
          "properties": {
            "similarity_percent": {"type": "INTEGER"},
            "similarities": {"type": "ARRAY", "items": {"type": "STRING"}},
            "differences": {
              "type": "ARRAY",
              "items": {
                "type": "OBJECT",
                "properties": {
                  "object_a": {"type": "STRING"},
                  "object_b": {"type": "STRING"},
                  "aspect": {"type": "STRING"}
                }
              }
            },
            "summary": {"type": "STRING"}
          },
          "required": ["similarity_percent", "similarities", "differences", "summary"]
        }
      }
    };

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      final text = jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(text);
    }
    throw Exception('Failed to compare objects');
  }

  /// CALL 5 - Ask AI
  Future<String> askAi(List<Map<String, dynamic>> history, {String level = 'School Student', String language = 'English'}) async {
    final url = Uri.parse('$_baseUrl/gemini-1.5-pro-latest:generateContent?key=$_apiKey');
    final payload = {
      "systemInstruction": {"parts": [{"text": _getSystemInstruction(level, language)}]},
      "contents": history,
    };

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
    }
    throw Exception('Failed to get AI response');
  }

  /// CALL 6 - Translate
  Future<Map<String, dynamic>> translateContent(String description, List<String> funFacts, String targetLanguage) async {
    final url = Uri.parse('$_baseUrl/gemini-1.5-flash-latest:generateContent?key=$_apiKey');
    final payload = {
      "systemInstruction": {"parts": [{"text": "You are a professional translator. Translate everything exactly to $targetLanguage."}]},
      "contents": [
        {"parts": [{"text": "Translate the following into $targetLanguage. Description: $description. Fun facts: ${funFacts.join(' | ')}"}]}
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "OBJECT",
          "properties": {
            "description_translated": {"type": "STRING"},
            "fun_facts_translated": {"type": "ARRAY", "items": {"type": "STRING"}}
          },
          "required": ["description_translated", "fun_facts_translated"]
        }
      }
    };

    final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload));
    if (response.statusCode == 200) {
      final text = jsonDecode(response.body)['candidates'][0]['content']['parts'][0]['text'];
      return jsonDecode(text);
    }
    throw Exception('Failed to translate');
  }
}
