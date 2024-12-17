import 'package:excel/excel.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quizz_vault_app/components/quiz_question_card.dart';
import 'package:quizz_vault_app/models/answer.dart';
import 'package:quizz_vault_app/models/difficulty.dart';
import 'package:quizz_vault_app/models/quiz_question.dart';
import 'package:quizz_vault_app/providers/quiz_provider.dart';

class QuizQuestionList extends StatelessWidget {
  const QuizQuestionList(
      {super.key,
      required this.questions,
      required this.quizId,
      required this.canEdit});
  final String quizId;
  final List<QuizQuestion> questions;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      replacement: const Text("Sem questões ainda"),
      child: Center(
        child: Column(
          children: [
            Text("Número de questões: ${questions.length}"),
            Visibility(
              visible: canEdit,
              child: ElevatedButton(
                onPressed:
                    QuizProvider.of(context, listen: false).clearQuestions,
                child: const Text("Apagar todas as questões"),
              ),
            ),
            ...questions.indexed
                .map((indexAndQuestion) => QuizQuestionCard(
                      question: indexAndQuestion.$2,
                      quizId: quizId,
                      canEdit: canEdit,
                      index: indexAndQuestion.$1 + 1,
                    ))
                .toList(),
            Visibility(
              visible: canEdit,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      QuizProvider.of(context, listen: false).addQuestion();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.add), Text("Adicionar Questão")],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: importQuiz(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_open_rounded),
                          Text("Importar de planilha")
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: exportQuiz(questions),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_open_rounded),
                          Text("Exportar para planilha")
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int getCorrectIndex(String letter) {
  return ['a', 'b', 'c', 'd'].indexOf(letter.toLowerCase());
}

String getCorrectLetter(int index) {
  return ['a', 'b', 'c', 'd'][index];
}

void Function() importQuiz(BuildContext context) {
  return () async {
    FilePickerResult? pickedFile = await FilePickerWeb.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile != null) {
      Uint8List bytes = pickedFile.files.single.bytes!;
      Excel excel = Excel.decodeBytes(bytes);
      Sheet sheet = excel.sheets.values.single;
      List<QuizQuestion> questions = [];

      for (List<Data?> row in sheet.rows.getRange(1, sheet.maxRows)) {
        var values = row.map((e) => e!.value);
        String questionText = values.elementAt(1).toString();
        String answerA = values.elementAt(2).toString();
        String answerB = values.elementAt(3).toString();
        String answerC = values.elementAt(4).toString();
        String answerD = values.elementAt(5).toString();
        String correct = values.elementAt(6).toString();
        int difficulty = int.parse(values.elementAt(7).toString());

        int correctIndex = getCorrectIndex(correct);
        List<Answer> asnwers = [answerA, answerB, answerC, answerD]
            .indexed
            .map((e) => Answer(
                id: e.$1.toString(), correct: e.$1 == correctIndex, text: e.$2))
            .toList();

        QuizQuestion question = QuizQuestion(
          id: '0',
          question: questionText,
          answers: asnwers,
          difficulty: Difficulty.values[difficulty],
        );

        questions.add(question);
      }

      for (QuizQuestion question in questions) {
        if (context.mounted) {
          await QuizProvider.of(context, listen: false).addQuestion();
        }
        String id = '';
        if (context.mounted) {
          id = QuizProvider.of(context, listen: false).quiz.questions.last.id;
        }
        question.id = id;
        if (context.mounted) {
          await QuizProvider.of(context, listen: false).saveQuestion(question);
        }
      }
    }
  };
}

void Function() exportQuiz(List<QuizQuestion> questions) {
  return () {
    Excel excel = Excel.createExcel();
    Sheet sheet = excel.sheets.values.single;
    sheet.appendRow([
      TextCellValue("Id"),
      TextCellValue("Pergunta"),
      TextCellValue("Resposta A"),
      TextCellValue("Resposta B"),
      TextCellValue("Resposta C"),
      TextCellValue("Resposta D"),
      TextCellValue("Correta"),
      TextCellValue("Dificuldade")
    ]);
    int questionIndex = 0;
    for (var question in questions) {
      List<CellValue?> values = [
        TextCellValue(questionIndex.toString()),
        TextCellValue(question.question),
        TextCellValue(question.answers[0].text),
        TextCellValue(question.answers[1].text),
        TextCellValue(question.answers[2].text),
        TextCellValue(question.answers[3].text),
        TextCellValue(
          getCorrectLetter(question.answers.indexWhere((a) => a.correct)),
        ),
        TextCellValue(question.difficulty.index.toString()),
      ];
      sheet.appendRow(values);
      questionIndex++;
    }

    excel.save(fileName: 'Planilha_Quizes.xlsx');
  };
}
