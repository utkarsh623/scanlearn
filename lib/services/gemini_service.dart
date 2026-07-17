import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  GenerativeModel _getModel(String modelName, String level, String language) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(
          "You are a highly intelligent educational AI assistant. The user's learning level is $level. "
          "Adjust your vocabulary and depth accordingly. You must provide incredibly detailed, rich, and accurate information. Respond entirely in $language."
      ),
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );
  }

  /// CALL 1 - Scan Object (Multimodal Vision Generation)
  Future<Map<String, dynamic>> scanObject(
    Uint8List imageBytes, {
    String level = 'School Student',
    String language = 'English',
  }) async {
    final prompt = "Carefully analyze this image and identify the primary object with high precision (e.g., instead of 'Food', say 'Belgian Waffle'). "
        "Provide a concise, engaging educational description of it (strictly 1 to 2 short paragraphs max). "
        "Return the response strictly as a JSON object with these exact keys: "
        "'object_name' (string - specific name of the object), 'category' (string), 'description' (string - concise, 1-2 paragraphs), 'fun_facts' (array of 3 highly interesting strings), and 'is_safe' (boolean).";

    String? lastError;

    try {
      final model = _getModel('gemini-flash-latest', level, language);
      final response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ]);
      String text = response.text ?? '';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(text);
    } catch (e) {
      lastError = e.toString();
      debugPrint('Gemini failed: $lastError');
    }
    
    // Fallback if vision model fails
    return {
      'object_name': 'Unknown Object',
      'category': 'Unknown',
      'description': 'I am currently unable to analyze this image. ($lastError).',
      'fun_facts': [
        'AI vision models require internet access.',
        'Sometimes API quotas can cause analysis to fail.',
        'Try checking your API key settings.'
      ],
      'is_safe': true
    };
  }

  /// CALL 2 - Ask AI
  Future<String> askAi(List<Map<String, dynamic>> history, {String level = 'School Student', String language = 'English'}) async {
    final model = _getModel('gemini-flash-latest', level, language);
    
    List<Content> contents = history.map((msg) {
      return Content(msg['role'], [TextPart(msg['parts'][0]['text'])]);
    }).toList();

    try {
      final response = await model.generateContent(contents);
      return response.text ?? 'No response generated.';
    } catch (e) {
      return 'I am currently unable to process your request. Please check your connection and API quota.';
    }
  }

  /// CALL 3 - Translate
  Future<Map<String, dynamic>> translateContent(String description, List<String> funFacts, String targetLanguage) async {
    final model = _getModel('gemini-flash-latest', 'Professional', targetLanguage);
    final prompt = "You are a professional translator. Translate the following exactly to $targetLanguage. "
        "Description: $description. Fun facts: ${funFacts.join(' | ')}. "
        "Return strictly as a JSON object with keys: 'description_translated' (string) and 'fun_facts_translated' (array of strings).";

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      String text = response.text ?? '';
      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(text);
    } catch (e) {
      return {
        'description_translated': 'Traducción no disponible. (Translation unavailable due to API error).',
        'fun_facts_translated': ['Error 1', 'Error 2']
      };
    }
  }
}
