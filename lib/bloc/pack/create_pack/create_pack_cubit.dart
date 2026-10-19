import 'package:flashcards/bloc/pack/create_pack/create_pack_state.dart';
import 'package:flashcards/data/repositories/flashcards/pack_repository.dart';
import 'package:flashcards/domain/models/flashcards/simple_pack/simple_pack.dart';
import 'package:flashcards/utils/form_validations.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePackCubit extends Cubit<CreatePackState> {
  final PackRepository _packRepo;

  CreatePackCubit({required PackRepository packRepo})
    : _packRepo = packRepo,
      super(CreatePackInitial());

  Future<void> createPack(
    String packName, {
    bool isPaid = false,
    String section = 'verbal',
  }) async {
    final errors = _validateForm(packName);
    if (errors.isNotEmpty) {
      emit(CreatePackFormInvalid(errors: errors));
      return;
    }

    emit(CreatePackLoading());

    final createResult = await _packRepo.createPack(
      packName,
      isPaid: isPaid,
      section: section,
    );
    switch (createResult) {
      case Error<SimplePack>(:final error):
        emit(CreatePackError(error: error));
        return;
      case Ok<SimplePack>():
        emit(CreatePackSuccessful(pack: createResult.value));
    }
  }

  Map<String, String> _validateForm(String packName) {
    final Map<String, String> errors = {};

    putErrorIfExists(errors, 'packName', validateString(packName));
    return errors;
  }
}
