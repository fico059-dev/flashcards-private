import 'package:flashcards/bloc/pack/delete_pack/delete_pack_state.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeletePackCubit extends Cubit<DeletePackState> {
  final PackRepository _packRepo;

  DeletePackCubit({required PackRepository packRepo})
    : _packRepo = packRepo,
      super(DeletePackInitial());

  /// Deletes the pack even if it has flashcards (they are deleted too).
  void deletePack(String packId) async {
    emit(DeletePackLoading());

    final deleteResult = await _packRepo.deletePackWithCards(packId);
    switch (deleteResult) {
      case Error<void>(:final error):
        emit(DeletePackError(error: error));
        return;
      case Ok<void>():
    }

    emit(DeletePackSuccessful());
  }

  void deletePackIfEmpty(String packId) async {
    emit(DeletePackLoading());

    final deleteResult = await _packRepo.deletePackEverywhereIfEmpty(packId);
    switch (deleteResult) {
      case Error<void>(:final error):
        emit(DeletePackError(error: error));
        return;
      case Ok<void>():
    }

    emit(DeletePackSuccessful());
  }
}
