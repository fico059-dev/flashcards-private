import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/notebook/highlight_repository.dart';
import 'package:flashcards/ui/pages/flashcards/review_bookmark_page.dart';
import 'package:flashcards/ui/widgets/notebook/highlights_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The student's notebook: highlighted passages and bookmarked cards.
@RoutePage()
class NotebookPage extends StatelessWidget {
  const NotebookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Builder(
              builder: (context) =>
                  SegmentedTabs(controller: DefaultTabController.of(context)),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                HighlightsList(repository: context.read<HighlightRepository>()),
                const _BookmarksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Highlights / Bookmarks switch.
class SegmentedTabs extends StatelessWidget {
  final TabController controller;

  const SegmentedTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.format_color_text),
              label: Text('Highlights'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.bookmark_outline),
              label: Text('Bookmarks'),
            ),
          ],
          selected: {controller.index},
          onSelectionChanged: (selected) =>
              controller.animateTo(selected.first),
        ),
      ),
    );
  }
}

class _BookmarksTab extends StatelessWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: () => context.router.push(
                FlashcardRoute(testType: TestType.bookmark),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Study my bookmarks'),
            ),
          ),
        ),
        const Expanded(child: BookmarksList()),
      ],
    );
  }
}
