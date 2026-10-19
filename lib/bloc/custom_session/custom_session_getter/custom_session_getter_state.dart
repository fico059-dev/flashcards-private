import 'package:flashcards/domain/models/flashcards/custom_session_summary/custom_session_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

part 'custom_session_getter_state.freezed.dart';

enum CustomSessionGetterStatus {
  initial,
  actionLoading,
  actionError,
  resetSuccessful,
  deleteSuccessful,
  renameSuccessful,
}

extension CustomSessionGetterStatusX on CustomSessionGetterStatus {
  bool get isInitial => this == CustomSessionGetterStatus.initial;

  bool get isActionLoading => this == CustomSessionGetterStatus.actionLoading;

  bool get isActionError => this == CustomSessionGetterStatus.actionError;

  bool get isResetSuccessful =>
      this == CustomSessionGetterStatus.resetSuccessful;

  bool get isDeleteSuccessful =>
      this == CustomSessionGetterStatus.deleteSuccessful;
}

@freezed
abstract class CustomSessionGetterState with _$CustomSessionGetterState {
  const factory CustomSessionGetterState({
    @Default(CustomSessionGetterStatus.initial)
    CustomSessionGetterStatus status,
    required PagingState<int, CustomSessionSummary> pagingState,
    bool? hasCards,
    Exception? error,
  }) = _CustomSessionGetterState;
}
