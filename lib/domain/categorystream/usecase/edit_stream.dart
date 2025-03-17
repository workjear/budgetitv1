import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category_stream.dart';

class EditStreamParams {
  final int streamId;
  final double stream;
  final String notes;
  final String accessToken;

  EditStreamParams({
    required this.streamId,
    required this.stream,
    required this.notes,
    required this.accessToken,
  });
}

class EditStreamUseCase extends UseCase<Either<Failure, String>, EditStreamParams> {
  @override
  Future<Either<Failure, String>> call({EditStreamParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryStreamRepository>().editStream(
      params.streamId,
      params.stream,
      params.notes,
      params.accessToken,
    );
  }
}