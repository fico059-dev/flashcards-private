import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_bloc.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_event.dart';
import 'package:flashcards/bloc/flashcards/manage_flashcards/manage_flashcards_state.dart';
import 'package:flashcards/config/router/router.dart';
import 'package:flashcards/data/repositories/flashcards/flashcard_repository.dart';
import 'package:flashcards/domain/models/flashcards/admin_pack/admin_pack.dart';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:flashcards/ui/constants/styles.dart';
import 'package:flashcards/ui/widgets/core/card_factory.dart';
import 'package:flashcards/ui/widgets/core/error_screen.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/edit_flashcard_card.dart';
import 'package:flashcards/ui/widgets/profile/admin_dashboard/flashcard_builder/manage_flashcard_packs/edit_flashcard_shimmer.dart';
import 'package:flashcards/utils/firebase_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

@RoutePage()
class ManagePackFlashcardsPage extends StatelessWidget {
  final AdminPack pack;

  const ManagePackFlashcardsPage({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ManageFlashcardsBloc(
            flashcardRepo: context.read<FlashcardRepository>(),
          ),
      child: _View(pack: pack),
    );
  }
}

class _View extends StatelessWidget {
  final AdminPack pack;

  const _View({super.key, required this.pack});

  Future<void> _handleRefresh(BuildContext context) {
    final completer = Completer<void>();
    context.read<ManageFlashcardsBloc>().add(
      ManageFlashcardRefresh(packId: pack.packId, completer: completer),
    );

    return completer.future.catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(extractErrorMessage(error))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إدارة بطاقات الحزمة"),
        leading: IconButton(
          onPressed: () => context.router.pop(),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: BlocListener<ManageFlashcardsBloc, ManageFlashcardsState>(
        listener: (context, state) {
          switch (state.status) {
            case ManageFlashcardsLoadedStatus.deleteSuccessful:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم حذف البطاقة")),
              );
              context.read<ManageFlashcardsBloc>().add(
                ManageFlashcardCacheRead(packId: pack.packId),
              );
              break;
            case ManageFlashcardsLoadedStatus.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(extractErrorMessage(state.error!))),
              );
              break;
            default:
              return;
          }
        },
        child: BlocBuilder<ManageFlashcardsBloc, ManageFlashcardsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => _handleRefresh(context),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: 20,
                      top: 10,
                      left: horizontalScreenPadding,
                      right: horizontalScreenPadding,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: CardFactory.info(
                        title: Text("اسحب للتعديل أو الحذف"),
                        subtitle: Text(
                          "اسحب لليسار لتعديل أو حذف بطاقة من هذه الحزمة،"
                          " أو اضغط مطولاً لعرض كل الخيارات.",
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalScreenPadding,
                    ),
                    sliver: PagedSliverList.separated(
                      state: state.pagingState,
                      fetchNextPage:
                          () => context
                              .read<ManageFlashcardsBloc>()
                              .fetchNextPage(pack.packId),
                      builderDelegate: PagedChildBuilderDelegate(
                        firstPageProgressIndicatorBuilder:
                            (context) => EditFlashcardShimmer(),
                        noItemsFoundIndicatorBuilder:
                            (context) => _EmptyListContainer(pack: pack),
                        firstPageErrorIndicatorBuilder:
                            (context) => ErrorScreen(
                              errorMessage: extractErrorMessage(
                                state.pagingState.error!,
                              ),
                              onReload:
                                  () => context
                                      .read<ManageFlashcardsBloc>()
                                      .fetchNextPage(pack.packId),
                            ),

                        itemBuilder: (context, item, index) {
                          // return EditFlashcardShimmer();
                          final card = item as Flashcard;
                          return EditFlashcardCard(
                            flashcard: card,
                            packId: pack.packId,
                          );
                        },
                        invisibleItemsThreshold: 0,
                      ),
                      separatorBuilder:
                          (BuildContext context, int index) =>
                              SizedBox(height: 10),
                    ),
                  ),
                ],
              ),
            );
          },
          //
        ),
      ),
    );
  }
}

class _EmptyListContainer extends StatelessWidget {
  final AdminPack pack;

  const _EmptyListContainer({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalScreenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Text(
            'ما فيه بطاقات في حزمة "${pack.packName}"',
            style: TextTheme.of(context).headlineSmall,
          ),
          FilledButton(
            onPressed: () {
              context.router.pop();
              context.router.push(CreateFlashcardRoute(pack: pack));
            },
            child: Text("إضافة بطاقات"),
          ),
        ],
      ),
    );
  }
}
