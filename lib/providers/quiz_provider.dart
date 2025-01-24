import 'package:cloud_firestore/cloud_firestore.dart';
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
  DocumentReference ref() {
    if (quiz.isPrivate) {
      return FirebaseFirestore.instance
          .collection('private_quizzes')
          .doc(quiz.ownerId)
          .collection('quizzes')
          .doc(quiz.id);
    }
    return FirebaseFirestore.instance.collection('quizzes').doc(quiz.id);
  }

  QuizProvider({required this.quiz, required this.isPrivate}) {
    Stream<Quiz> stream = ref().snapshots().map((doc) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
    DocumentReference newQuestionRef =
        await ref().collection('questions').add({});
    QuizQuestion newQuestion = QuizQuestion(
      id: newQuestionRef.id,
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
    if (newQuiz.isPrivate) {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quiz.id)
          .delete();

      await FirebaseFirestore.instance
          .collection('private_quizzes')
          .doc(newQuiz.ownerId)
          .collection('quizzes')
          .doc(newQuiz.id)
          .set(newQuiz.toJson());
    } else {
      await FirebaseFirestore.instance
          .collection('private_quizzes')
          .doc(quiz.ownerId)
          .collection('quizzes')
          .doc(quiz.id)
          .delete();

      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(newQuiz.id)
          .set(newQuiz.toJson());
    }
  }

  Future<void> saveQuestion(QuizQuestion question) async {
    await ref()
        .collection('questions')
        .doc(question.id)
        .update(question.toJson());
  }

  Future<void> removeQuestion(String questionId) async {
    await ref().collection('questions').doc(questionId).delete();
  }

  Future<void> clearQuestions() async {
    quiz.questions = [];
    final query = await ref().collection('questions').get();
    await Future.wait(query.docs.map((doc) => doc.reference.delete()));
  }

  static QuizProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<QuizProvider>(context, listen: listen);
  }
}
