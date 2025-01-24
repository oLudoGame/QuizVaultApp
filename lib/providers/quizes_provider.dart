import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_vault_app/models/quiz.dart';

class QuizzesProvider extends ChangeNotifier {
  List<Quiz> quizzes = [];
  List<Quiz> privateQuizzes = [];
  bool loading = true;

  CollectionReference publicQuizzesRef =
      FirebaseFirestore.instance.collection('quizzes');

  CollectionReference privateQuizzesRef = FirebaseFirestore.instance
      .collection('private_quizzes')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('quizzes');

  QuizzesProvider() {
    // Stream for public quizzes
    publicQuizzesRef.snapshots().listen((snapshot) {
      quizzes = snapshot.docs.map((doc) {
        Quiz quiz = Quiz.fromJson(doc.data() as Map<String, dynamic>);
        quiz.id = doc.id; // Assign Firestore doc ID to the quiz
        return quiz;
      }).toList();
      loading = false;
      notifyListeners();
    });

    // Stream for private quizzes
    privateQuizzesRef.snapshots().listen((snapshot) {
      privateQuizzes = snapshot.docs.map((doc) {
        Quiz quiz = Quiz.fromJson(doc.data() as Map<String, dynamic>);
        quiz.id = doc.id; // Assign Firestore doc ID to the quiz
        quiz.isPrivate = true; // Mark as private
        return quiz;
      }).toList();
      loading = false;
      notifyListeners();
    });
  }

  Future<void> addQuiz({bool isPrivate = false}) async {
    try {
      CollectionReference ref = isPrivate ? privateQuizzesRef : publicQuizzesRef;
      DocumentReference newQuiz = await ref.add(Quiz(
        id: ref.id,
        description: "Descrição",
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        questions: [],
        title: "Título",
        isPrivate: isPrivate,
      ).toJson());

      // Optionally set the quiz ID if needed
      await newQuiz.update({'id': newQuiz.id});
    } catch (e) {
      debugPrint('Erro ao adicionar quiz: $e');
      throw Exception("Não foi possível adicionar o quiz.");
    }
  }

  Future<void> removeQuiz(String quizId, {bool isPrivate = false}) async {
    try {
      CollectionReference ref = isPrivate ? privateQuizzesRef : publicQuizzesRef;
      await ref.doc(quizId).delete();
    } catch (e) {
      debugPrint('Erro ao remover quiz: $e');
      throw Exception("Não foi possível remover o quiz.");
    }
  }

  static QuizzesProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<QuizzesProvider>(context, listen: listen);
  }
}
