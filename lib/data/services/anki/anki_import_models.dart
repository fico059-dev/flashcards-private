import 'dart:typed_data';

import 'package:flashcards/data/services/anki/anki_text_converter.dart';

/// An image referenced by an Anki card. It is extracted from the deck to a
/// temporary file, so large decks don't have to fit in memory.
///
/// A side with several images keeps all of them in [paths]; they are joined
/// into one picture when uploaded, since a flashcard side has one image.
class AnkiImage {
  final String name;

  /// Where the image was extracted to (phone app).
  final String path;
  final List<String> extraPaths;

  /// The image itself, when there are no files (website).
  final Uint8List? bytes;
  final List<Uint8List> extraBytes;

  /// Names of every image of the side, to notice when they change.
  final List<String> names;

  const AnkiImage({
    required this.name,
    this.path = '',
    this.extraPaths = const [],
    this.bytes,
    this.extraBytes = const [],
    this.names = const [],
  });

  List<String> get paths => [path, ...extraPaths];

  List<Uint8List> get allBytes => [?bytes, ...extraBytes];

  int get count =>
      bytes != null ? 1 + extraBytes.length : 1 + extraPaths.length;

  /// Identifies the image(s) of this side, e.g. "a.png|b.png".
  String get key => (names.isEmpty ? [name] : names).join('|');
}

/// A card ready to be imported into a Flashpedz pack.
class AnkiCard {
  final String question;
  final String answer;
  final AnkiImage? questionImage;
  final AnkiImage? answerImage;
  final List<String> tags;
  final bool isCloze;

  /// Identifies the Anki note (and cloze number) the card came from, so a
  /// later import of the same deck updates it instead of adding it again.
  final String? sourceKey;

  const AnkiCard({
    required this.question,
    required this.answer,
    this.questionImage,
    this.answerImage,
    this.tags = const [],
    this.isCloze = false,
    this.sourceKey,
  });

  /// The images of both sides, to notice when they change.
  String get imagesKey =>
      '${questionImage?.key ?? ''}/${answerImage?.key ?? ''}';
}

/// Everything read from an Anki export, before anything is uploaded.
class AnkiParseResult {
  final List<AnkiCard> cards;

  /// Notes that could not be turned into a card (e.g. empty front side).
  final int skippedNotes;

  /// Images that were referenced by cards but missing from the export.
  final int missingImages;

  /// Card sides with more than one image. They are joined into one picture.
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

  /// Anki's id for the note, the same in every export of the deck.
  final String? guid;

  const AnkiNote({required this.fields, required this.tags, this.guid});
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
        sourceKey: note.guid == null ? null : 'anki:${note.guid}',
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
            sourceKey: note.guid == null ? null : 'anki:${note.guid}:c$number',
          ),
        )
        .where((card) => card.question.isNotEmpty)
        .toList();
  }

  /// All the images of a side, in order. Several images are later joined
  /// into one picture.
  AnkiImage? _pickImage(String html) {
    final found = <AnkiImage>[];
    for (final name in extractImageNames(html).toSet()) {
      final image = _findImage(name);
      if (image == null) {
        missingImages++;
      } else if (!found.any(
        (f) => f.name == image.name && f.path == image.path,
      )) {
        found.add(image);
      }
    }
    if (found.isEmpty) return null;
    if (found.length > 1) extraImagesDropped++;
    return AnkiImage(
      name: found.first.name,
      path: found.first.path,
      extraPaths: [for (final image in found.skip(1)) image.path],
      bytes: found.first.bytes,
      extraBytes: [for (final image in found.skip(1)) ?image.bytes],
      names: [for (final image in found) image.name],
    );
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
