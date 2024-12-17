import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_vault_app/models/answer.dart';
import 'package:quizz_vault_app/models/difficulty.dart';
import 'package:quizz_vault_app/models/quiz.dart';
import 'package:quizz_vault_app/models/quiz_question.dart';

class QuizProvider extends ChangeNotifier {
  Quiz quiz;
  bool loading = true;
  bool isPrivate;
  DatabaseReference ref() {
    if (quiz.isPrivate) {
      return FirebaseDatabase.instance
          .ref('private_quizzes/${quiz.ownerId}')
          .child(quiz.id);
    }
    return FirebaseDatabase.instance.ref('quizzes').child(quiz.id);
  }

  QuizProvider({required this.quiz, required this.isPrivate}) {
    Stream<Quiz> stream = ref().onValue.map((event) {
      final Map<String, dynamic> data =
          event.snapshot.value as Map<String, dynamic>;
      Quiz newQuiz = Quiz.fromJson(data);
      newQuiz.isPrivate = isPrivate;
      return newQuiz;
    });

    stream.listen((newQuiz) {
      quiz = newQuiz;
      loading = false;
      notifyListeners();
    });
  }

  Future<void> addQuestion() async {
    DatabaseReference newQuestionRef = ref().child('questions').push();
    QuizQuestion newQuestion = QuizQuestion(
      id: newQuestionRef.key!,
      question: "Pergunta da questão",
      answers: [],
      difficulty: Difficulty.easy,
    );
    for (var i = 0; i <= 3; i++) {
      newQuestion.answers.add(
        Answer(id: i.toString(), correct: i == 0, text: 'Resposta'),
      );
    }
    await newQuestionRef.set(newQuestion.toJson());
  }

  Future<void> saveQuiz(Quiz newQuiz) async {
    // o novo é privado
    if (newQuiz.isPrivate) {
      await FirebaseDatabase.instance.ref('quizzes/${quiz.id}').remove();
      await FirebaseDatabase.instance
          .ref('private_quizzes/${newQuiz.ownerId}/${newQuiz.id}')
          .update(newQuiz.toJson());
    }
    // o novo é público
    else {
      await FirebaseDatabase.instance
          .ref('private_quizzes/${quiz.ownerId}/${quiz.id}')
          .remove();
      await FirebaseDatabase.instance
          .ref('quizzes/${newQuiz.id}')
          .update(newQuiz.toJson());
    }
  }

  Future<void> saveQuestion(QuizQuestion question) async {
    await ref().child('questions').child(question.id).update(question.toJson());
  }

  Future<void> removeQuestion(String questionId) async {
    await ref().child('questions').child(questionId).remove();
  }

  Future<void> clearQuestions() async {
    quiz.questions = [];
    await ref().child('questions').remove();
  }

  static QuizProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<QuizProvider>(context, listen: listen);
  }
}
