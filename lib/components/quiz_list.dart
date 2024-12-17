import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_vault_app/components/quiz_card.dart';
import 'package:quizz_vault_app/providers/quizes_provider.dart';

class QuizList extends StatelessWidget {
  const QuizList({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuizzesProvider(),
      child: Consumer<QuizzesProvider>(
        builder: (context, quizesProvider, child) {
          if (quizesProvider.loading) {
            return const CircularProgressIndicator();
          }

          return Center(
            child: Column(
              children: [
                ...quizesProvider.privateQuizzes.map((quiz) => QuizCard(
                      quiz: quiz,
                      isOwner: quiz.ownerId ==
                          FirebaseAuth.instance.currentUser!.uid,
                    )),
                ...quizesProvider.quizzes.map((quiz) => QuizCard(
                      quiz: quiz,
                      isOwner: quiz.ownerId ==
                          FirebaseAuth.instance.currentUser!.uid,
                    )),
                ElevatedButton(
                  onPressed: () {
                    QuizzesProvider.of(context, listen: false).addQuiz();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.add), Text("Adicionar Quiz")],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
