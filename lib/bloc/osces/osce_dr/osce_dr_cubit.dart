import 'package:flashcards/bloc/osces/osce_dr/osce_dr_state.dart';
import 'package:flashcards/data/repositories/osces/osce_repository.dart';
import 'package:flashcards/data/services/api/dto/osces/osce/patch_osce/patch_osce_dto.dart';
import 'package:flashcards/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OsceDrCubit extends Cubit<OsceDrState> {
  final OsceRepository _osceRepo;

  /// Id of the OSCE made by [createOsce], once it succeeded.
  String? createdOsceId;

  OsceDrCubit({required OsceRepository osceRepo})
    : _osceRepo = osceRepo,
      super(OsceDrInitial());

  void createOsce(String name, String scenario, {bool isPaid = false}) async {
    if (state is! OsceDrInitial) return;

    emit(OsceDrLoading());

    final result = await _osceRepo.addSimpleOsce(
      name: name,
      scenario: scenario,
      isPaid: isPaid,
    );

    switch (result) {
      case Error<String>(:final error):
        emit(OsceDrError(error: error));
      case Ok<String>(:final value):
        createdOsceId = value;
        emit(OsceDrSuccess());
    }
  }

  void deleteOsce(String osceId) async {
    if (state is! OsceDrInitial) return;

    emit(OsceDrLoading());

    final result = await _osceRepo.deleteOsce(osceId);
    switch (result) {
      case Error<void>(:final error):
        emit(OsceDrError(error: error));
      case Ok<void>():
        emit(OsceDrSuccess());
    }
  }

  void renameOsce({
    required String osceId,
    required String name,
    required String scenario,
  }) async {
    if (state is! OsceDrInitial) return;
    emit(OsceDrLoading());

    final dto = PatchOsceDto(scenario: scenario, name: name);
    final result = await _osceRepo.patchOsce(osceId, dto);
    switch (result) {
      case Error<void>(:final error):
        print(error);
        emit(OsceDrError(error: error));
      case Ok<void>():
        emit(OsceDrSuccess());
    }
  }

  Future<void> setOscePaid(String osceId, bool value) async {
    if (state is! OsceDrInitial) return;
    emit(OsceDrLoading());
    final result = await _osceRepo.patchOsce(
      osceId,
      PatchOsceDto(isPaid: value),
    );
    switch (result) {
      case Error<void>(:final error):
        emit(OsceDrError(error: error));
      case Ok<void>():
        emit(OsceDrSuccess());
    }
  }
}
