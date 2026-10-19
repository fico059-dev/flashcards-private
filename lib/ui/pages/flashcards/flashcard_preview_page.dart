import 'package:auto_route/auto_route.dart';
import 'package:flashcards/domain/models/core/image_data_wrapper.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/images/image_preview.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/answer_container/widgets/flashcard_answer.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/main_card_container.dart';
import 'package:flashcards/ui/widgets/flashcard/flashcard_test/main_card/widgets/question_text.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';

@RoutePage()
class FlashcardPreviewPage extends StatefulWidget {
  final Flashcard flashcard;
  final ImageDataWrapper? questionImageData;
  final ImageDataWrapper? answerImageData;

  const FlashcardPreviewPage({
    super.key,
    required this.flashcard,
    this.questionImageData,
    this.answerImageData,
  });

  @override
  State<FlashcardPreviewPage> createState() => _FlashcardPreviewPageState();
}

class _FlashcardPreviewPageState extends State<FlashcardPreviewPage> {
  bool _isAnswerShown = false;
  late final ImageDataWrapper questionImageData;
  late final ImageDataWrapper answerImageData;

  void toggleAnswer() {
    setState(() {
      _isAnswerShown = !_isAnswerShown;
    });
  }

  @override
  void initState() {
    super.initState();
    questionImageData =
        (widget.questionImageData == null || widget.questionImageData!.isEmpty)
        ? ImageDataWrapper(imageDownloadUrl: widget.flashcard.questionImageUrl)
        : widget.questionImageData!;

    answerImageData =
        (widget.answerImageData == null || widget.answerImageData!.isEmpty)
        ? ImageDataWrapper(imageDownloadUrl: widget.flashcard.answerImageUrl)
        : widget.answerImageData!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview Flashcard"),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: ReadableWidth(
        maxWidth: 820,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalScreenPadding,
              right: horizontalScreenPadding,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ImagePreview(
                      downloadUrl: questionImageData.imageDownloadUrl,
                      imageBytes: questionImageData.pickedImage?.bytes,
                      imageFile: questionImageData.pickedImage?.file,
                      height: 200,
                      showTextWhenEmpty: false,
                    ),
                  ),
                  SizedBox(height: 20),
                  MainCardContainer(
                    child: QuestionText(
                      question: _isAnswerShown
                          ? revealClozeQuestion(widget.flashcard.question)
                          : redactClozeQuestion(widget.flashcard.question),
                    ),
                  ),

                  SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: toggleAnswer,
                            child: Text(
                              _isAnswerShown ? "Hide Answer" : "Reveal",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  if (_isAnswerShown)
                    FlashcardAnswer(
                      answer: widget.flashcard.answer,
                      answerImagePreview: Center(
                        child: ImagePreview(
                          downloadUrl: answerImageData.imageDownloadUrl,
                          imageBytes: answerImageData.pickedImage?.bytes,
                          imageFile: answerImageData.pickedImage?.file,
                          height: 150,
                          showTextWhenEmpty: false,
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
