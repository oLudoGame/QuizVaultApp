import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quizz_vault_app/components/quiz_question_list.dart';
import 'package:quizz_vault_app/models/quiz.dart';
import 'package:quizz_vault_app/models/qz_user.dart';
import 'package:quizz_vault_app/providers/quiz_provider.dart';

class QuizDetails extends StatefulWidget {
  const QuizDetails({super.key, required this.quiz, required this.isOwner});
  final bool isOwner;
  final Quiz quiz;

  @override
  State<QuizDetails> createState() => _QuizDetailsState();
}

class _QuizDetailsState extends State<QuizDetails> {
  bool editMode = false;
  late String description;
  late String title;
  late bool isPrivate;
  @override
  void initState() {
    super.initState();
    title = widget.quiz.title;
    description = widget.quiz.description;
    isPrivate = widget.quiz.isPrivate;
  }

  Future<QzUser> loadOwner() async {
    var data = await FirebaseDatabase.instance
        .ref('users')
        .child(widget.quiz.ownerId)
        .get();
    return QzUser.fromJson(data.value as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          QuizProvider(quiz: widget.quiz, isPrivate: widget.quiz.isPrivate),
      child: Consumer<QuizProvider>(builder: (context, quizProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.quiz.title),
            actions: [
              if (widget.isOwner)
                IconButton(
                  onPressed: () {
                    setState(() {
                      editMode = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: SizedBox(
              child: Column(
                children: [
                  FutureBuilder(
                      future: loadOwner(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        QzUser owner = snapshot.data!;
                        return Container(
                          width: 500,
                          alignment: Alignment.topCenter,
                          child: Visibility(
                            visible: !editMode,
                            replacement: Column(children: [
                              TextFormField(
                                initialValue: quizProvider.quiz.title,
                                onChanged: (value) => setState(() {
                                  title = value;
                                }),
                              ),
                              TextFormField(
                                initialValue: quizProvider.quiz.description,
                                onChanged: (value) => setState(() {
                                  description = value;
                                }),
                              ),
                              Row(
                                children: [
                                  const Text("Privado"),
                                  Checkbox(
                                    value: isPrivate,
                                    onChanged: (value) => setState(() {
                                      isPrivate = value!;
                                    }),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => setState(() {
                                      editMode = false;
                                    }),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      Quiz quiz = quizProvider.quiz;
                                      quiz.title = title;
                                      quiz.description = description;
                                      quiz.isPrivate = isPrivate;
                                      QuizProvider.of(context, listen: false)
                                          .saveQuiz(quiz);
                                      editMode = false;
                                    }),
                                    child: const Text("Salvar"),
                                  ),
                                ],
                              ),
                            ]),
                            child: Column(
                              children: [
                                Text(quizProvider.quiz.title),
                                Text(quizProvider.quiz.description),
                                Text(owner.name),
                                Text(quizProvider.quiz.isPrivate
                                    ? "Privado"
                                    : "Público"),
                              ],
                            ),
                          ),
                        );
                      }),
                  QuizQuestionList(
                    questions: quizProvider.quiz.questions,
                    quizId: quizProvider.quiz.id,
                    canEdit: FirebaseAuth.instance.currentUser!.uid ==
                        quizProvider.quiz.ownerId,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
