import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/flashcard/flashcard_event.dart';
import 'package:flashcards/bloc/pack/single_pack_getter/single_pack/single_pack_getter_cubit.dart';
import 'package:flashcards/bloc/pack/single_pack_getter/single_pack/single_pack_getter_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/pack/pack.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/theme/theme_extensions.dart';
import 'package:flashcards/ui/widgets/core/subs_status_icon.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flashcards/utils/util_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showSinglePackBottomSheet(
  BuildContext context,
  String packId,
  bool? hasCards,
) {
  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: scrollableSheet(
      (context) => _SinglePackWidget(packId: packId, hasCards: hasCards),
    ),
  );
}

class _SinglePackWidget extends StatelessWidget {
  final String packId;
  final bool? hasCards;

  const _SinglePackWidget({
    super.key,
    required this.packId,
    required this.hasCards,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SinglePackGetterCubit(packRepo: context.read<PackRepository>()),
      child: _View(packId: packId, hasCards: hasCards),
    );
  }
}

class _View extends StatefulWidget {
  final String packId;
  final bool? hasCards;

  const _View({super.key, required this.packId, required this.hasCards});

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  @override
  void initState() {
    super.initState();
    context.read<SinglePackGetterCubit>().getPack(widget.packId);
  }

  void _onStartTest(Pack pack) async {
    if (pack.isPaid == true) {
      final ok = await ensureCardsAccess(context);
      if (!ok) return;
    }

    if (!mounted) return;
    context.router.pop();
    context.router.replace(
      FlashcardRoute(testType: TestType.regular, pack: pack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: bottomSheetPadding,
      child: Wrap(
        children: [
          BlocBuilder<SinglePackGetterCubit, SinglePackGetterState>(
            builder: (context, state) {
              switch (state) {
                case SinglePackGetterInitial():
                case SinglePackGetterLoading():
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  );
                case SinglePackGetterError(:final error):
                  return Center(
                    child: Text(
                      "Error loading pack: ${extractErrorMessage(error)}",
                    ),
                  );
                case SinglePackGetterLoaded(:final pack):
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.folder),
                        title: Text(pack.name),
                        subtitle: Text("Flashcards: ${pack.flashcardsCount}"),
                        trailing: SubsStatusIcon(
                          isPaid: pack.isPaid,
                          hasAccess: widget.hasCards,
                          size: 20,
                        ),
                      ),

                      Divider(),

                      if (!pack.isPaid || widget.hasCards == true) ...[
                        if (pack.dueCount != -1)
                          ListTile(
                            leading: Icon(
                              Icons.schedule,
                              color: context.colors.secondary,
                            ),
                            title: Text('Due: ${pack.dueCount}'),
                          ),
                        if (pack.learningCount != -1)
                          ListTile(
                            leading: Icon(
                              Icons.auto_stories,
                              color: context.colors.tertiary,
                            ),
                            title: Text('Learning: ${pack.learningCount}'),
                          ),
                        if (pack.newCount != -1)
                          ListTile(
                            leading: Icon(
                              Icons.fiber_new,
                              color: context.customColors.success,
                            ),
                            title: Text('New: ${pack.newCount}'),
                          ),

                        if (pack.dueCount != -1 ||
                            pack.learningCount != -1 ||
                            pack.newCount != -1)
                          Divider(),
                      ],

                      ListTile(
                        leading: Icon(
                          Icons.play_arrow,
                          color: context.colors.primary,
                        ),
                        title: Text("Start test"),
                        onTap: () => _onStartTest(pack),
                      ),
                    ],
                  );
              }
            },
          ),
        ],
      ),
    );
  }
}
