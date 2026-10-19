import 'package:flutter/material.dart';

class BatchCounter extends StatelessWidget {
  final int currentBatch;
  final int currentFlashcard;
  final int allFlashcards;

  const BatchCounter({
    super.key,
    required this.currentBatch,
    required this.currentFlashcard,
    required this.allFlashcards,
  });

  @override
  Widget build(BuildContext context) {
    return Text("الدفعة $currentBatch، سؤال $currentFlashcard/$allFlashcards");
  }
}
