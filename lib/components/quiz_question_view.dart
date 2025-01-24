import 'package:flutter/material.dart';
import 'package:quizz_vault_app/components/answers_list.dart';
import 'package:quizz_vault_app/models/difficulty.dart';
import 'package:quizz_vault_app/models/quiz_question.dart';
import 'package:quizz_vault_app/providers/quiz_provider.dart';

class QuizQuestionView extends StatelessWidget {
  const QuizQuestionView({
    super.key,
    required this.question,
    required this.onChangedMode,
    required this.canEdit,
    required this.index,
  });
  final QuizQuestion question;
  final VoidCallback onChangedMode;
  final bool canEdit;
  final int index;

  String difficultyPtBr(Difficulty? difficulty) {
    if (difficulty == null) {
      return "Indefinido";
    }
    return {
      Difficulty.easy: "Fácil",
      Difficulty.medium: "Média",
      Difficulty.hard: "Difícil",
    }[difficulty]!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Text(
            index.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          title: Text(question.question,
              style: Theme.of(context).textTheme.displaySmall),
          subtitle: Text("Dificuldade: ${difficultyPtBr(question.difficulty)}"),
          trailing: canEdit
              ? SizedBox(
                  width: 200,
                  child: EditButtons(
                      onChangedMode: onChangedMode, question: question),
                )
              : null,
        ),
        AnswersList(answers: question.answers),
      ],
    );
  }
}

class EditButtons extends StatelessWidget {
  const EditButtons({
    super.key,
    required this.onChangedMode,
    required this.question,
  });

  final VoidCallback onChangedMode;
  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () => onChangedMode(),
          child: Container(
            padding: const EdgeInsets.all(5),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.edit),
                Text("Editar"),
              ],
            ),
          ),
        ),
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
                title: const Text("Apagar questão"),
                content: Text(
                    'Deseja mesmo apagar a questão "${question.question}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Apagar"),
                  )
                ],
              ),
            );

            if (delete && context.mounted) {
              QuizProvider.of(context, listen: false)
                  .removeQuestion(question.id);
            }
          },
        ),
      ],
    );
  }
}
