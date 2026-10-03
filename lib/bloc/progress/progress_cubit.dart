import 'package:flashcards/data/repositories/progress/progress_repository.dart';
import 'package:flashcards/domain/models/progress/card_progress.dart';
import 'package:flashcards/domain/models/progress/osce_progress.dart';
import 'package:flashcards/domain/models/progress/study_log.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Data of one Progress tab: loading, loaded or failed.
class ProgressSection<T> {
  final T? data;
  final Exception? error;
  final bool isLoading;

  const ProgressSection({this.data, this.error, this.isLoading = false});

  ProgressSection<T> loading() => ProgressSection(data: data, isLoading: true);
}

class ProgressState {
  final ProgressSection<CardProgressStats> cards;
  final ProgressSection<OsceProgressStats> osce;
  final StudyGoal goal;

  const ProgressState({
    this.cards = const ProgressSection(isLoading: true),
    this.osce = const ProgressSection(isLoading: true),
    this.goal = const StudyGoal(),
  });

  ProgressState copyWith({
    ProgressSection<CardProgressStats>? cards,
    ProgressSection<OsceProgressStats>? osce,
    StudyGoal? goal,
  }) => ProgressState(
    cards: cards ?? this.cards,
    osce: osce ?? this.osce,
    goal: goal ?? this.goal,
  );
}

class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository _repo;

  ProgressCubit({required ProgressRepository progressRepo})
    : _repo = progressRepo,
      super(const ProgressState());

  Future<void> load({bool refresh = false}) async {
    final log = await _repo.getLog();
    if (isClosed) return;
    emit(
      state.copyWith(
        goal: log.goal,
        cards: state.cards.loading(),
        osce: state.osce.loading(),
      ),
    );
    await Future.wait([_loadCards(refresh), _loadOsce(refresh)]);
  }

  Future<void> saveGoal(StudyGoal goal) async {
    await _repo.saveGoal(goal);
    if (isClosed) return;
    emit(state.copyWith(goal: goal));
    await Future.wait([_loadCards(false), _loadOsce(false)]);
  }

  Future<void> _loadCards(bool refresh) async {
    final result = await _repo.getCardStats(refresh: refresh);
    if (isClosed) return;
    emit(
      state.copyWith(
        cards: switch (result) {
          Ok(:final value) => ProgressSection(data: value),
          Error(:final error) => ProgressSection(
            data: state.cards.data,
            error: error,
          ),
        },
      ),
    );
  }

  Future<void> _loadOsce(bool refresh) async {
    final result = await _repo.getOsceStats(refresh: refresh);
    if (isClosed) return;
    emit(
      state.copyWith(
        osce: switch (result) {
          Ok(:final value) => ProgressSection(data: value),
          Error(:final error) => ProgressSection(
            data: state.osce.data,
            error: error,
          ),
        },
      ),
    );
  }
}
