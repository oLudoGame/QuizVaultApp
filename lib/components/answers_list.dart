import 'package:flutter/material.dart';
import 'package:quizz_vault_app/models/answer.dart';

class AnswersList extends StatelessWidget {
  const AnswersList({super.key, required this.answers});
  final List<Answer> answers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: answers
          .map((answer) => Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      color: answer.correct ? Colors.green : Colors.red,
                    ),
                    Expanded(
                      child: Text(answer.text),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
