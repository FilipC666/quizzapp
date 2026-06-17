import 'dart:convert';
import 'dart:io';
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
    try {
      final response = await http.get(Uri.parse(_categoriesUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List categoriesJson = data['trivia_categories'];
        final categories = categoriesJson.map((json) => Category.fromJson(json)).toList();
        await HiveService.saveCategories(categories);
        return categories;
      } else {
        throw Exception('Server error while fetching categories.');
      }
    } on SocketException {
      final cached = HiveService.getCategories();
      if (cached.isNotEmpty) return cached;
      throw Exception('No internet connection.');
    } catch (e) {
      final cached = HiveService.getCategories();
      if (cached.isNotEmpty) return cached;
      throw Exception('Failed to fetch categories.');
    }
  }

  Future<List<Question>> fetchQuestions(int categoryId, String difficulty) async {
    final cacheKey = '${categoryId}_${difficulty.toLowerCase()}';
    try {
      final uri = Uri.parse('$_questionsUrl?amount=10&category=$categoryId&difficulty=${difficulty.toLowerCase()}');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['response_code'] != 0) {
          throw Exception('No questions found for this category.');
        }
        final List questionsJson = data['results'];
        final questions = questionsJson.map((json) {
          final q = Question.fromJson(json);
          return Question(
            question: _unescape.convert(q.question),
            correctAnswer: _unescape.convert(q.correctAnswer),
            incorrectAnswers: q.incorrectAnswers.map((e) => _unescape.convert(e)).toList(),
            allAnswers: q.allAnswers.map((e) => _unescape.convert(e)).toList(),
          );
        }).toList();
        
        await HiveService.saveQuestions(cacheKey, questions);
        return questions;
      } else {
        throw Exception('Server error (Code: ${response.statusCode})');
      }
    } on SocketException {
      final cached = HiveService.getQuestions(cacheKey);
      if (cached.isNotEmpty) return cached;
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      final cached = HiveService.getQuestions(cacheKey);
      if (cached.isNotEmpty) return cached;
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred while fetching questions.');
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
  static const String _questionsBox = 'questionsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(QuizResultAdapter());
    Hive.registerAdapter(QuestionAdapter());
    await Hive.openBox<Category>(_categoriesBox);
    await Hive.openBox<QuizResult>(_resultsBox);
    await Hive.openBox<List>(_questionsBox);
  }

  static Future<void> saveCategories(List<Category> categories) async {
    final box = Hive.box<Category>(_categoriesBox);
    await box.clear();
    await box.addAll(categories);
  }

  static List<Category> getCategories() {
    return Hive.box<Category>(_categoriesBox).values.toList();
  }

  static Future<void> saveQuestions(String key, List<Question> questions) async {
    final box = Hive.box<List>(_questionsBox);
    await box.put(key, questions);
  }

  static List<Question> getQuestions(String key) {
    final box = Hive.box<List>(_questionsBox);
    final List? questions = box.get(key);
    return questions?.cast<Question>() ?? [];
  }

  static Future<void> saveResult(QuizResult result) async {
    final box = Hive.box<QuizResult>(_resultsBox);
    await box.add(result);
  }

  static List<QuizResult> getResults() {
    return Hive.box<QuizResult>(_resultsBox).values.toList();
  }
}
