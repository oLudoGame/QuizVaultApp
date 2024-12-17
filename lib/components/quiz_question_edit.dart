import 'package:flutter/material.dart';
import 'package:quizz_vault_app/models/answer.dart';
import 'package:quizz_vault_app/models/difficulty.dart';
import 'package:quizz_vault_app/models/quiz_question.dart';
import 'package:quizz_vault_app/providers/quiz_provider.dart';

class QuizQuestionEdit extends StatefulWidget {
  const QuizQuestionEdit({
    super.key,
    required this.question,
    required this.quizId,
    required this.onChangedMode,
  });
  final QuizQuestion question;
  final String quizId;
  final VoidCallback onChangedMode;

  @override
  State<QuizQuestionEdit> createState() => _QuizQuestionEditState();
}

class _QuizQuestionEditState extends State<QuizQuestionEdit> {
  late final QuizQuestion newQuestion;
  @override
  void initState() {
    super.initState();
    newQuestion = widget.question.clone();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: TextFormField(
            initialValue: widget.question.question,
            maxLines: null,
            style: Theme.of(context).textTheme.displaySmall,
            onChanged: (value) {
              setState(() => newQuestion.question = value);
            },
          ),
          subtitle: Row(
            children: [
              const Text("Dificuldade:"),
              SegmentedButton<Difficulty>(
                multiSelectionEnabled: false,
                segments: List.generate(3, (index) {
                  return ButtonSegment(
                    value: Difficulty.values[index],
                    label: Text(() {
                      switch (Difficulty.values[index]) {
                        case Difficulty.easy:
                          return "Fácil";
                        case Difficulty.medium:
                          return "Média";
                        case Difficulty.hard:
                          return "Difícil";
                        default:
                          return "Indefinido";
                      }
                    }()),
                  );
                }),
                selected: <Difficulty>{newQuestion.difficulty},
                onSelectionChanged: (difficultySelected) {
                  setState(() {
                    newQuestion.difficulty = difficultySelected.single;
                  });
                },
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () => widget.onChangedMode(),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Cancelar"),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  QuizProvider.of(context, listen: false)
                      .saveQuestion(newQuestion);
                  widget.onChangedMode();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.check),
                      Text("Salvar"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: newQuestion.answers.indexed.map((e) {
            int index = e.$1;
            Answer currentAnswer = e.$2;
            return Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Radio(
                    value: true,
                    groupValue: currentAnswer.correct,
                    onChanged: (value) {
                      setState(() {
                        for (Answer answer in newQuestion.answers) {
                          answer.correct = false;
                        }
                        newQuestion.answers[index].correct = value!;
                      });
                    },
                  ),
                  Icon(
                    Icons.circle,
                    color: e.$2.correct ? Colors.green : Colors.red,
                  ),
                  Expanded(
                    child: TextFormField(
                      maxLines: null,
                      initialValue: e.$2.text,
                      onChanged: (value) {
                        setState(() {
                          newQuestion.answers[e.$1].text = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
