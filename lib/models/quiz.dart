import 'package:quizz_vault_app/models/quiz_question.dart';

class Quiz {
  String id;
  String title;
  String description;
  String ownerId;
  List<QuizQuestion> questions;
  bool isPrivate;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.questions,
    required this.isPrivate,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final List<dynamic> questionsJson = json['questions'] ?? [];
    final List<QuizQuestion> questionsList = questionsJson
        .map((questionJson) => QuizQuestion.fromJson(questionJson))
        .toList();
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ownerId: json['owner_id'],
      questions: questionsList,
      isPrivate: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'owner_id': ownerId,
      'questions': [for (var question in questions) question.toJson()],
    };
  }
}
