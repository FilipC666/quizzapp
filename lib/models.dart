import 'package:hive/hive.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 0;

  @override
  Category read(BinaryReader reader) {
    return Category(
      id: reader.readInt(),
      name: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
  }
}

class Question {
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> allAnswers;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.allAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> incorrect = List<String>.from(json['incorrect_answers']);
    List<String> all = List<String>.from(incorrect)..add(json['correct_answer']);
    all.shuffle();

    return Question(
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: incorrect,
      allAnswers: all,
    );
  }
}

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 2;

  @override
  Question read(BinaryReader reader) {
    return Question(
      question: reader.readString(),
      correctAnswer: reader.readString(),
      incorrectAnswers: reader.readStringList(),
      allAnswers: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer.writeString(obj.question);
    writer.writeString(obj.correctAnswer);
    writer.writeStringList(obj.incorrectAnswers);
    writer.writeStringList(obj.allAnswers);
  }
}

class QuizResult {
  final int correctAnswers;
  final int totalQuestions;
  final DateTime date;

  QuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.date,
  });
}

class QuizResultAdapter extends TypeAdapter<QuizResult> {
  @override
  final int typeId = 1;

  @override
  QuizResult read(BinaryReader reader) {
    return QuizResult(
      correctAnswers: reader.readInt(),
      totalQuestions: reader.readInt(),
      date: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, QuizResult obj) {
    writer.writeInt(obj.correctAnswers);
    writer.writeInt(obj.totalQuestions);
    writer.writeString(obj.date.toIso8601String());
  }
}
