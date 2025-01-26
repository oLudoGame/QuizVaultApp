import 'package:quizz_vault_app/models/answer.dart';
import 'package:quizz_vault_app/models/difficulty.dart';

class QuizQuestion {
  String id;
  String question;
  List<Answer> answers;
  Difficulty difficulty;
  bool isNew = false;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.difficulty,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    var answersJson = json['answers'] as List<dynamic>? ?? [];
    var answersList =
        answersJson.map((answerJson) => Answer.fromJson(answerJson)).toList();

    return QuizQuestion(
      id: json['id'],
      question: json['question'] ?? [],
      answers: answersList,
      difficulty: Difficulty.values[json['difficulty']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answers': [for (var answer in answers) answer.toJson()],
      'difficulty': difficulty.index,
    };
  }

  QuizQuestion clone() {
    return QuizQuestion(
      id: id,
      question: question,
      answers: answers.map((answer) => answer.clone()).toList(),
      difficulty: difficulty,
    );
  }
}
