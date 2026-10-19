import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/custom_session/pack_filter/pack_filter_bloc.dart';
import 'package:flashcards/bloc/custom_session/pack_filter/pack_filter_event.dart';
import 'package:flashcards/bloc/custom_session/pack_filter/pack_filter_state.dart';
import 'package:flashcards/domain/enums/pack_selected_filter.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/core/loading_overlay_listener.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FlashcardsFilterPage extends StatefulWidget {
  final List<String> selectedPacks;
  final int allCount;

  const FlashcardsFilterPage({
    super.key,
    required this.selectedPacks,
    required this.allCount,
  });

  @override
  State<FlashcardsFilterPage> createState() => _FlashcardsFilterPageState();
}

class _FlashcardsFilterPageState extends State<FlashcardsFilterPage> {
  void _loadCounts(List<String> packIds, int allCount) {
    context.read<PackFilterBloc>().add(
      PackFilterCountsFetched(packIds: packIds, allCount: allCount),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCounts(widget.selectedPacks, widget.allCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlayListener<PackFilterBloc, PackFilterState>(
        isLoading: (state) => state is PackFilterLoading,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
          child: BlocBuilder<PackFilterBloc, PackFilterState>(
            builder: (context, state) {
              switch (state) {
                case PackFilterError(:final error):
                  return ErrorScreen(
                    errorMessage: extractErrorMessage(error),
                    onReload:
                        () =>
                            _loadCounts(widget.selectedPacks, widget.allCount),
                  );
                case PackFilterLoaded():
                  return _LoadedContent(state: state);
                default:
                  return SizedBox.expand();
              }
            },
          ),
        ),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final PackFilterLoaded state;

  const _LoadedContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedFilter;
    final bookmarkCount = state.packFilterCounts.bookmarkedCount;
    final seenCount = state.packFilterCounts.seenCount;
    final ignoredCount = state.packFilterCounts.ignoredCount;
    final allCount = state.packFilterCounts.allCount;

    void selectOption(PackSelectedFilter filter) {
      context.read<PackFilterBloc>().add(PackFilterSelected(filter: filter));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardFactory.info(
          title: Text("اختر الفلتر"),
          subtitle: Text(
            "حدد نوع البطاقات اللي تبي تركّز عليها "
            "داخل الحزم المختارة.",
          ),
        ),

        SizedBox(height: 40),

        Wrap(
          spacing: 20,
          children: [
            ChoiceChip(
              label: Text("كل البطاقات $allCount"),
              selected: selected == PackSelectedFilter.all,
              onSelected: (_) => selectOption(PackSelectedFilter.all),
            ),
            ChoiceChip(
              label: Text("اللي شفتها ${state.packFilterCounts.seenCount}"),
              selected: selected == PackSelectedFilter.seen,
              onSelected:
                  seenCount > 0
                      ? (_) => selectOption(PackSelectedFilter.seen)
                      : null,
            ),
            ChoiceChip(
              label: Text(
                "المحفوظة ${state.packFilterCounts.bookmarkedCount}",
              ),
              selected: selected == PackSelectedFilter.bookmarked,
              onSelected:
                  bookmarkCount > 0
                      ? (_) => selectOption(PackSelectedFilter.bookmarked)
                      : null,
            ),
            ChoiceChip(
              label: Text("المتجاهَلة ${state.packFilterCounts.ignoredCount}"),
              selected: selected == PackSelectedFilter.ignored,
              onSelected:
                  ignoredCount > 0
                      ? (_) => selectOption(PackSelectedFilter.ignored)
                      : null,
            ),
          ],
        ),

        SizedBox(height: 40),

        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "• "),
              TextSpan(
                text: "كل البطاقات",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " – كل بطاقات الحزم المختارة.\n",
              ),

              TextSpan(text: "• "),
              TextSpan(
                text: "المُشاهَدة",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " – البطاقات اللي مرّت عليك سابقاً فقط.\n"),

              TextSpan(text: "• "),
              TextSpan(
                text: "المحفوظة",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " – البطاقات اللي علّمتها مهمة.\n"),

              TextSpan(text: "• "),
              TextSpan(
                text: "المتجاهَلة",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " – البطاقات اللي طلبت تجاهلها سابقاً."),
            ],
          ),
        ),
      ],
    );
  }
}
