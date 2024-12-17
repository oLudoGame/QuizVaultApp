import 'package:flutter/foundation.dart';
import 'package:quizz_vault_app/models/quiz_question.dart';

class NewQuestionProvider extends ChangeNotifier {
  NewQuestionProvider(this.question);
  QuizQuestion question;

  void updateQuestion(QuizQuestion newQuestion) {
    question = newQuestion;
    notifyListeners();
  }
}