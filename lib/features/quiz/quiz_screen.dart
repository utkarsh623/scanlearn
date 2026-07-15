import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scan_learn/core/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

final quizFutureProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final scan = ref.watch(currentScanProvider);
  if (scan == null) throw Exception('No scan data');
  final gemini = ref.watch(geminiServiceProvider);
  return gemini.generateQuiz(scan.objectName, scan.description ?? '', scan.funFacts ?? []);
});

final currentQuestionIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
final scoreProvider = StateProvider.autoDispose<int>((ref) => 0);
final selectedAnswerProvider = StateProvider.autoDispose<int?>((ref) => null);

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  Future<void> _saveScore(int score, int total, String scanId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client.from('quiz_scores').insert({
        'user_id': userId,
        'scan_id': scanId,
        'score': score,
        'total': total,
      });
    } catch (e) {
      debugPrint('Save score failed: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizFutureProvider);
    final currentIndex = ref.watch(currentQuestionIndexProvider);
    final selectedAnswer = ref.watch(selectedAnswerProvider);
    final score = ref.watch(scoreProvider);
    final scan = ref.watch(currentScanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: quizAsync.when(
        data: (questions) {
          if (currentIndex >= questions.length) {
            // Quiz finished
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scan != null) _saveScore(score, questions.length, scan.id);
            });
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Quiz Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Your Score: $score / ${questions.length}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
                  )
                ],
              ).animate().fadeIn().scale(),
            );
          }

          final q = questions[currentIndex];
          final options = (q['options'] as List).cast<String>();
          final correctIndex = q['correct_index'] as int;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Question ${currentIndex + 1} of ${questions.length}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                Text(q['question'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                ...options.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final text = entry.value;
                  final isSelected = selectedAnswer == idx;
                  final isCorrect = idx == correctIndex;
                  
                  Color? bgColor;
                  if (selectedAnswer != null) {
                    if (isCorrect) bgColor = Colors.green[100];
                    else if (isSelected) bgColor = Colors.red[100];
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      tileColor: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300),
                      ),
                      title: Text(text),
                      onTap: selectedAnswer != null ? null : () {
                        ref.read(selectedAnswerProvider.notifier).state = idx;
                        if (idx == correctIndex) {
                          ref.read(scoreProvider.notifier).state++;
                        }
                      },
                    ),
                  );
                }),
                const Spacer(),
                if (selectedAnswer != null) ...[
                  Text(q['explanation'], style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(selectedAnswerProvider.notifier).state = null;
                      ref.read(currentQuestionIndexProvider.notifier).state++;
                    },
                    child: Text(currentIndex < questions.length - 1 ? 'Next Question' : 'Finish Quiz'),
                  )
                ]
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error generating quiz: $e')),
      ),
    );
  }
}
