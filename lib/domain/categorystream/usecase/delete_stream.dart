import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category_stream.dart';

class DeleteStreamParams {
  final int streamId;
  final String accessToken;

  DeleteStreamParams({required this.streamId, required this.accessToken});
}

class DeleteStreamUseCase extends UseCase<Either<Failure, String>, DeleteStreamParams> {
  @override
  Future<Either<Failure, String>> call({DeleteStreamParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryStreamRepository>()
        .deleteStream(params.streamId, params.accessToken);
  }
}