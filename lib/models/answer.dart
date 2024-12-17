class Answer {
  String id;
  bool correct;
  String text;

  Answer({
    required this.id,
    required this.correct,
    required this.text,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      correct: json['correct'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'correct': correct,
      'text': text,
    };
  }

  Answer clone() {
    return Answer(id: id, correct: correct, text: text);
  }
}
