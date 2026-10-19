import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/fc_review_getter/fc_review_getter_cubit.dart';
import 'package:flashcards/bloc/flashcards/fc_review_getter/fc_review_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/custom_drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FcReviewSheetHeader extends StatelessWidget {
  const FcReviewSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    void onReport({
      required Flashcard flashcard,
      required String packId,
      required String packName,
    }) {
      context.router.push(
        ReportFlashcardRoute(
          packId: packId,
          flashcard: flashcard,
          packName: packName,
        ),
      );
    }

    void onToggleBookmark() {
      context.read<FcReviewGetterCubit>().toggleBookmark();
    }

    return Container(
      //color: Colors.red,
      child: Column(
        children: [
          CustomDragHandle(),
          Container(
            padding: bottomSheetHorizontalPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "مراجعة البطاقة",
                  style: TextTheme.of(
                    context,
                  ).titleLarge?.merge(TextStyle(fontWeight: FontWeight.w600)),
                ),

                BlocBuilder<FcReviewGetterCubit, FcReviewGetterState>(
                  builder: (context, state) {
                    late final bool enabled;
                    late final String packId;
                    late final String packName;
                    late final Flashcard flashcard;
                    bool isBookmarked = false;
                    switch (state) {
                      case FcReviewGetterInitial():
                      case FcReviewGetterLoading():
                      case FcReviewGetterError():
                      case FcReviewGetterForbidden():
                        enabled = false;
                      case FcReviewGetterLoaded(:final fcReview):
                        enabled = true;
                        packId = fcReview.record.packId;
                        packName = fcReview.packName;
                        flashcard = fcReview.record.flashcard!;
                        isBookmarked = fcReview.record.hasBookmark;
                    }

                    return Row(
                      spacing: 5,
                      children: [
                        Tooltip(
                          message: "الإبلاغ عن هذه البطاقة",
                          child: IconButton(
                            onPressed: enabled
                                ? () => onReport(
                                    packName: packName,
                                    flashcard: flashcard,
                                    packId: packId,
                                  )
                                : () {},
                            icon: Icon(
                              Icons.flag_outlined,
                              color: enabled
                                  ? context.colors.primaryContainer
                                  : context.colors.outlineVariant,
                            ),
                          ),
                        ),
                        Tooltip(
                          message: isBookmarked
                              ? "إزالة من المحفوظة"
                              : "حفظ هذه البطاقة",
                          child: IconButton(
                            onPressed: enabled ? onToggleBookmark : () {},
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: enabled
                                  ? context.colors.primaryContainer
                                  : context.colors.outlineVariant,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
