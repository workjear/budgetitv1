import 'package:budgeit/presentation/streams/bloc/streams_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/service_locator.dart';

import '../../../domain/categorystream/usecase/edit_stream.dart';
class EditStreamCubit extends Cubit<EditStreamState> {
  EditStreamCubit() : super(EditStreamInitial());

  Future<void> editStream({
    required int streamId,
    required double stream,
    required String notes,
    required String accessToken,
  }) async {
    emit(EditStreamLoading());

    debugPrint('Notes:$notes');
    final result = await sl<EditStreamUseCase>().call(

      params: EditStreamParams(
        streamId: streamId,
        stream: stream,
        notes: notes,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) => emit(EditStreamError(failure)),
          (message) => emit(EditStreamSuccess(message)),
    );
  }
}