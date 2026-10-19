import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:flashcards/bloc/custom_session/pack_picker/pack_picker_bloc.dart';
import 'package:flashcards/bloc/custom_session/pack_picker/pack_picker_event.dart';
import 'package:flashcards/bloc/custom_session/pack_picker/pack_picker_state.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/custom_session/pack_selection_card.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/ui/widgets/core/desktop_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class PackSelectionPage extends StatelessWidget {
  const PackSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> handleRefresh() {
      final completer = Completer<void>();
      context.read<PackPickerBloc>().add(
        PackPickerRefresh(completer: completer),
      );

      return completer.future.catchError((error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
      });
    }

    return Scaffold(
      body: ReadableWidth(
        maxWidth: 820,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
          child: RefreshIndicator(
            onRefresh: handleRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CardFactory.info(
                    title: Text("How it works?"),
                    isThreeLine: true,
                    subtitle: Text(
                      "Choose one or more flashcard packs you want to include in"
                      " your session. These packs will define the content"
                      " you'll be reviewing or testing yourself on.",
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 10)),

                BlocBuilder<PackPickerBloc, PackPickerState>(
                  builder: (context, state) {
                    return PagedSliverList(
                      state: state.pagingState,
                      fetchNextPage: context
                          .read<PackPickerBloc>()
                          .fetchNextPage,
                      builderDelegate: PagedChildBuilderDelegate(
                        itemBuilder: (context, item, index) {
                          final pack = item as SimplePack;
                          final isSelected =
                              state.selectedPacksMap[pack] == true;

                          return PackSelectionCard(
                            hasCards: state.hasCards,
                            pack: pack,
                            selected: isSelected,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
