import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:html_unescape/html_unescape.dart';
import 'models.dart';

class ApiService {
  static const String _categoriesUrl = 'https://opentdb.com/api_category.php';
  static const String _questionsUrl = 'https://opentdb.com/api.php';
  final HtmlUnescape _unescape = HtmlUnescape();

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse(_categoriesUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List categoriesJson = data['trivia_categories'];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Question>> fetchQuestions(int categoryId, String difficulty) async {
    final uri = Uri.parse('$_questionsUrl?amount=10&category=$categoryId&difficulty=${difficulty.toLowerCase()}');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['response_code'] != 0) {
        throw Exception('No questions found');
      }
      final List questionsJson = data['results'];
      return questionsJson.map((json) {
        final q = Question.fromJson(json);
        return Question(
          question: _unescape.convert(q.question),
          correctAnswer: _unescape.convert(q.correctAnswer),
          incorrectAnswers: q.incorrectAnswers.map((e) => _unescape.convert(e)).toList(),
          allAnswers: q.allAnswers.map((e) => _unescape.convert(e)).toList(),
        );
      }).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}

class FirebaseService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logQuizStarted(int categoryId) async {
    await _analytics.logEvent(
      name: 'quiz_started',
      parameters: {'category_id': categoryId},
    );
  }

  Future<void> logQuizCompleted(int score) async {
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {'score': score},
    );
  }

  Future<void> logCategoryRefreshed() async {
    await _analytics.logEvent(
      name: 'category_refreshed',
    );
  }

  static void initializeCrashlytics() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}

class HiveService {
  static const String _categoriesBox = 'categoriesBox';
  static const String _resultsBox = 'resultsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(QuizResultAdapter());
    await Hive.openBox<Category>(_categoriesBox);
    await Hive.openBox<QuizResult>(_resultsBox);
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final box = Hive.box<Category>(_categoriesBox);
    await box.clear();
    await box.addAll(categories);
  }

  static List<Category> getCategories() {
    return Hive.box<Category>(_categoriesBox).values.toList();
  }

  static Future<void> saveResult(QuizResult result) async {
    final box = Hive.box<QuizResult>(_resultsBox);
    await box.add(result);
  }

  static List<QuizResult> getResults() {
    return Hive.box<QuizResult>(_resultsBox).values.toList();
  }
}