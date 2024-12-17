import 'package:flutter/material.dart';
import 'package:quizz_vault_app/components/quiz_question_edit.dart';
import 'package:quizz_vault_app/components/quiz_question_view.dart';
import 'package:quizz_vault_app/models/quiz_question.dart';

class QuizQuestionCard extends StatefulWidget {
  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.quizId,
    required this.canEdit,
    required this.index,
  });
  final String quizId;
  final QuizQuestion question;
  final bool canEdit;
  final int index;

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}

class _QuizQuestionCardState extends State<QuizQuestionCard> {
  void changeMode() {
    setState(() {
      viewMode = !viewMode;
    });
  }

  bool viewMode = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: 700,
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Visibility(
            visible: viewMode,
            replacement: QuizQuestionEdit(
              question: widget.question,
              quizId: widget.quizId,
              onChangedMode: changeMode,
            ),
            child: QuizQuestionView(
              question: widget.question,
              onChangedMode: changeMode,
              canEdit: widget.canEdit,
              index: widget.index,
            ),
          ),
        ),
      ),
    );
  }
}
