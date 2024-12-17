import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizz_vault_app/components/quiz_details.dart';
import 'package:quizz_vault_app/models/quiz.dart';
import 'package:quizz_vault_app/providers/quizes_provider.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({super.key, required this.quiz, required this.isOwner});
  final bool isOwner;
  final Quiz quiz;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: 400,
      child: Card(
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(quiz.title, maxLines: null)),
                  Row(
                    children: [
                      const Icon(Icons.list),
                      Text("${quiz.questions.length} questões"),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isOwner)
                    IconButton.outlined(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        weight: 0.5,
                      ),
                      onPressed: () async {
                        bool delete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Apagar quiz"),
                            content: Text(
                                'Deseja mesmo apagar o quiz "${quiz.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text("Apagar"),
                              )
                            ],
                          ),
                        );

                        if (delete && context.mounted) {
                          QuizzesProvider.of(context, listen: false)
                              .removeQuiz(quiz.id);
                        }
                      },
                    ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              QuizDetails(quiz: quiz, isOwner: isOwner),
                        ),
                      );
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye_outlined),
                          Text("Detalhes"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
