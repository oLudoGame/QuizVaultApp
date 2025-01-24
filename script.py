from typing import List, Dict

import firebase_admin
from firebase_admin import credentials, firestore, db
from dataclasses import dataclass, field


@dataclass
class User:
    id: str
    nome: str
    email: str

    @classmethod
    def from_dict(cls, d):
        return cls(**d)


@dataclass
class Answer:
    id: str
    text: str
    correct: bool

    @classmethod
    def from_dict(cls, data):
        return cls(
            id=data.get('id'),
            text=data.get('text'),
            correct=data.get('correct'),
        )


@dataclass
class Question:
    id: str
    question: str
    difficulty: int
    answers: List[Answer] = field(default_factory=list)

    def __post_init__(self):
        if not self.answers:
            self.answers = []

    @classmethod
    def from_dict(cls, data):
        return cls(
            id=data.get('id'),
            question=data.get('question'),
            difficulty=data.get('difficulty'),
            answers=[Answer.from_dict(a) for a in data.get('answers', [])],
        )


@dataclass
class Quiz:
    id: str
    title: str
    owner_id: str
    description: str
    questions: Dict[str, Question] = field(default_factory=dict)

    def __post_init__(self):
        if not self.questions:
            self.questions = {}

    @classmethod
    def from_dict(cls, data):
        return cls(
            id=data.get('id'),
            title=data.get('title'),
            owner_id=data.get('owner_id'),
            description=data.get('description'),
            questions={q_id: Question.from_dict(q) for q_id, q in data.get('questions', {}).items()}
        )


# Use a service account.
cred = credentials.Certificate('cred.json')

app = firebase_admin.initialize_app(cred, {'databaseURL': 'https://quizvaultapp-ea5fb-default-rtdb.firebaseio.com/'})

store = firestore.client()

ref = db.reference('quizzes')

quizzes = [Quiz.from_dict(data) for data in ref.get().values()]

for quiz in quizzes:
    quiz_doc = store.collection('quizzes').document(quiz.id)
    quiz_data = vars(quiz).copy()
    quiz_data.pop('questions')
    quiz_doc.set(quiz_data)
    questions_ref = quiz_doc.collection('questions')
    if not hasattr(quiz, 'questions'):
        print(f'Quiz {quiz.title} has no questions')
        continue
    for question in quiz.questions.values():
        question_doc = questions_ref.document(question.id)
        question_data = vars(question).copy()
        question_data.pop('answers')
        question_doc.set(question_data)
        answers_ref = question_doc.collection('answers')
        if not hasattr(question, 'answers'):
            print(f'Question {question.question} has no answers')
            continue
        for answer in question.answers:
            answer_doc = answers_ref.document(answer.id)
            answer_data = vars(answer)
            answer_doc.set(answer_data)
