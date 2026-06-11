import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../services.dart';
import '../providers.dart';

class QuizScreen extends StatefulWidget {
  final Category category;

  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();

  List<Question> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _firebaseService.logQuizStarted(widget.category.id);
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final difficulty = Provider.of<SettingsProvider>(context, listen: false).difficulty;
    try {
      final questions = await _apiService.fetchQuestions(widget.category.id, difficulty);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching questions: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    }
  }

  void _answerQuestion(String selectedAnswer) async {
    if (selectedAnswer == _questions[_currentIndex].correctAnswer) {
      _score++;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      await HiveService.saveResult(QuizResult(
        correctAnswers: _score,
        totalQuestions: _questions.length,
        date: DateTime.now(),
      ));
      await _firebaseService.logQuizCompleted(_score);
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quiz Finished!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            Text(
              'Your score: $_score / ${_questions.length}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Finish'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade900, Colors.purple.shade700],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / _questions.length,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 10,
                ),
                const SizedBox(height: 10),
                Text(
                  'Question ${_currentIndex + 1} of ${_questions.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            _questions[_currentIndex].question,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ..._questions[_currentIndex].allAnswers.map((answer) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple.shade900,
                        padding: const EdgeInsets.all(18.0),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        side: BorderSide(color: Colors.deepPurple.shade100, width: 1),
                      ),
                      onPressed: () => _answerQuestion(answer),
                      child: Text(
                        answer,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
