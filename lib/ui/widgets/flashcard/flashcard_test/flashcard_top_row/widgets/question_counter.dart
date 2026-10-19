import 'package:flutter/material.dart';

class QuestionCounter extends StatelessWidget {
  final int currentFlashcard;
  final int allFlashcards;

  const QuestionCounter({
    super.key,
    required this.currentFlashcard,
    required this.allFlashcards,
  });

  @override
  Widget build(BuildContext context) {
    return Text("سؤال $currentFlashcard/$allFlashcards");
  }
}
