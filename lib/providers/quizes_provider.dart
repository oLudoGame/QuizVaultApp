import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_vault_app/models/quiz.dart';

class QuizzesProvider extends ChangeNotifier {
  List<Quiz> quizzes = [];
  List<Quiz> privateQuizzes = [];
  bool loading = true;
  DatabaseReference quizzesRef = FirebaseDatabase.instance.ref('quizzes');
  DatabaseReference privateQuizzesRef = FirebaseDatabase.instance
      .ref('private_quizzes/${FirebaseAuth.instance.currentUser!.uid}');

  QuizzesProvider() {
    Stream<List<Quiz>> quizzesStream = quizzesRef.onValue.map((event) {
      final data = event.snapshot.value as dynamic;
      if (data == null) {
        return [];
      }
      return data.values.map((value) => Quiz.fromJson(value)).toList();
    });
    Stream<List<Quiz>> privateQuizzesStream =
        privateQuizzesRef.onValue.map((event) {
      final data = event.snapshot.value as LinkedHashMap<Object?, Object?>?;
      if (data == null) {
        return [];
      }
      List<Quiz> quizzesList =
          data.cast<String, dynamic>().entries.map((entry) => Quiz.fromJson(entry.value)).toList();
      for (var i = 0; i < quizzesList.length; i++) {
        quizzesList[i].isPrivate = true;
      }
      return quizzesList;
    });

    privateQuizzesStream.listen((newQuizes) {
      privateQuizzes = newQuizes;
      loading = false;
      notifyListeners();
    });

    quizzesStream.listen((newQuizes) {
      quizzes = newQuizes;
      loading = false;
      notifyListeners();
    });
  }

  Future<void> addQuiz() async {
    DatabaseReference newQuiz = quizzesRef.push();
    await newQuiz.set(Quiz(
      description: "Descrição",
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      questions: [],
      title: "Título",
      id: newQuiz.key!,
      isPrivate: false,
    ).toJson());
  }

  Future<void> removeQuiz(String quizId) async {
    await quizzesRef.child(quizId).remove();
  }

  static QuizzesProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<QuizzesProvider>(context, listen: listen);
  }
}
