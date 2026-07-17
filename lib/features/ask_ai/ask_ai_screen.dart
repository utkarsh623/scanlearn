import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AskAiScreen extends ConsumerStatefulWidget {
  const AskAiScreen({super.key});

  @override
  ConsumerState<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> {
  late final GenerativeModel _model;
  late final LlmProvider _provider;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );
    
    // We try to use GeminiProvider from the toolkit if available
    // If flutter_ai_toolkit uses GeminiProvider directly, this works.
    _provider = GeminiProvider(model: _model);
    
    setState(() {
      _isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scan = ref.watch(currentScanProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Ask AI about ${scan?.objectName ?? "Object"}')),
      body: _isInit 
          ? LlmChatView(
              provider: _provider,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
