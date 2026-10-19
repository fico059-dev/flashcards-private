import 'package:firebase_storage/firebase_storage.dart';

/// Service for accessing storage references for database documents. Data is organized
/// exactly like in firestore db, references to the data are the same as in db.
class CloudStorageService {
  final _storageRef = FirebaseStorage.instance.ref();

  // Flashcard images, one for question, one for answer
  Reference get _flashcardsRef => _storageRef.child("flashcards");

  Reference _getFlashcardRef(String flashcardId) =>
      _flashcardsRef.child(flashcardId);

  /// It gives you reference to the flashcard's question image, the path looks like this:
  /// /flashcards/{flashcardId}/question.jpg
  Reference getFlashcardQuestionImageRef(String flashcardId) =>
      _getFlashcardRef(flashcardId).child("question.jpg");

  /// It gives you reference to the flashcard's answer image, the path looks like this:
  /// /flashcards/{flashcardId}/answer.jpg
  Reference getFlashcardAnswerImageRef(String flashcardId) =>
      _getFlashcardRef(flashcardId).child("answer.jpg");
}
