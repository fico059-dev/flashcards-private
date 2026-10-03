import 'package:flashcards/data/services/anki/anki_text_converter.dart';

/// An image referenced by an Anki card. It is extracted from the deck to a
/// temporary file, so large decks don't have to fit in memory.
class AnkiImage {
  final String name;
  final String path;

  const AnkiImage({required this.name, required this.path});
}

/// A card ready to be imported into a Flashpedz pack.
class AnkiCard {
  final String question;
  final String answer;
  final AnkiImage? questionImage;
  final AnkiImage? answerImage;
  final List<String> tags;
  final bool isCloze;

  const AnkiCard({
    required this.question,
    required this.answer,
    this.questionImage,
    this.answerImage,
    this.tags = const [],
    this.isCloze = false,
  });
}

/// Everything read from an Anki export, before anything is uploaded.
class AnkiParseResult {
  final List<AnkiCard> cards;

  /// Notes that could not be turned into a card (e.g. empty front side).
  final int skippedNotes;

  /// Images that were referenced by cards but missing from the export.
  final int missingImages;

  /// Cards that referenced more than one image on a side. Flashpedz supports
  /// one image per side, so only the first one is kept.
  final int extraImagesDropped;

  const AnkiParseResult({
    required this.cards,
    required this.skippedNotes,
    required this.missingImages,
    required this.extraImagesDropped,
  });
}

/// Thrown when the file can't be read as an Anki export. [message] is shown to
/// the admin as is.
class AnkiImportException implements Exception {
  final String message;

  const AnkiImportException(this.message);

  @override
  String toString() => message;
}

/// A raw Anki note: its fields (HTML) and tags.
class AnkiNote {
  final List<String> fields;
  final List<String> tags;

  const AnkiNote({required this.fields, required this.tags});
}

/// Turns raw Anki notes into Flashpedz cards. A cloze note produces one card
/// per cloze number, just like in Anki.
class AnkiNoteConverter {
  final AnkiImage? Function(String name) _findImage;

  int skippedNotes = 0;
  int missingImages = 0;
  int extraImagesDropped = 0;

  AnkiNoteConverter({required AnkiImage? Function(String name) findImage})
    : _findImage = findImage;

  AnkiParseResult convert(Iterable<AnkiNote> notes) {
    final cards = <AnkiCard>[];
    for (final note in notes) {
      final converted = _convertNote(note);
      if (converted.isEmpty) {
        skippedNotes++;
      }
      cards.addAll(converted);
    }
    return AnkiParseResult(
      cards: cards,
      skippedNotes: skippedNotes,
      missingImages: missingImages,
      extraImagesDropped: extraImagesDropped,
    );
  }

  List<AnkiCard> _convertNote(AnkiNote note) {
    final fields = note.fields;
    if (fields.isEmpty) return [];

    final clozeFieldIndex = fields.indexWhere(hasCloze);
    if (clozeFieldIndex != -1) {
      return _convertClozeNote(note, clozeFieldIndex);
    }

    final front = fields[0];
    // Use the first non-empty field after the front as the answer.
    final back = fields
        .skip(1)
        .firstWhere(
          (f) =>
              htmlToPlainText(f).isNotEmpty || extractImageNames(f).isNotEmpty,
          orElse: () => '',
        );

    final question = htmlToPlainText(front);
    final answer = htmlToPlainText(back);
    final questionImage = _pickImage(front);
    final answerImage = _pickImage(back);

    if (question.isEmpty && questionImage == null) return [];
    if (answer.isEmpty && answerImage == null) return [];

    return [
      AnkiCard(
        question: _orImagePlaceholder(question),
        answer: _orImagePlaceholder(answer),
        questionImage: questionImage,
        answerImage: answerImage,
        tags: note.tags,
      ),
    ];
  }

  List<AnkiCard> _convertClozeNote(AnkiNote note, int clozeFieldIndex) {
    final text = note.fields[clozeFieldIndex];
    final extra = note.fields
        .whereIndexed((i, _) => i != clozeFieldIndex)
        .firstWhere(
          (f) =>
              htmlToPlainText(f).isNotEmpty || extractImageNames(f).isNotEmpty,
          orElse: () => '',
        );

    final questionImage = _pickImage(text);
    final answerImage = _pickImage(extra);
    final extraText = htmlToPlainText(extra);
    // The question is revealed when the card is flipped, so the full text is a
    // good answer when the note has no "Back Extra".
    final answer = extraText.isNotEmpty
        ? extraText
        : htmlToPlainText(revealAllClozes(text));

    return findClozeNumbers(text)
        .map(
          (number) => AnkiCard(
            question: buildClozeQuestion(text, number),
            answer: _orImagePlaceholder(answer),
            questionImage: questionImage,
            answerImage: answerImage,
            tags: note.tags,
            isCloze: true,
          ),
        )
        .where((card) => card.question.isNotEmpty)
        .toList();
  }

  AnkiImage? _pickImage(String html) {
    final names = extractImageNames(html);
    if (names.isEmpty) return null;
    if (names.length > 1) extraImagesDropped++;

    for (final name in names) {
      final image = _findImage(name);
      if (image != null) return image;
      missingImages++;
    }
    return null;
  }

  /// Flashpedz requires question and answer text, so image-only sides get a
  /// short label.
  String _orImagePlaceholder(String text) =>
      text.isEmpty ? '(See image)' : text;
}

extension<T> on Iterable<T> {
  Iterable<T> whereIndexed(bool Function(int index, T element) test) sync* {
    var index = 0;
    for (final element in this) {
      if (test(index++, element)) yield element;
    }
  }
}
