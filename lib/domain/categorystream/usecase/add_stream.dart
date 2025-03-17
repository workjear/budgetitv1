import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category_stream.dart';

class AddStreamParams {
  final int categoryId;
  final double stream;
  final String notes;
  final String accessToken;

  AddStreamParams({
    required this.categoryId,
    required this.stream,
    required this.notes,
    required this.accessToken,
  });
}

class AddStreamUseCase extends UseCase<Either<Failure, String>, AddStreamParams> {
  @override
  Future<Either<Failure, String>> call({AddStreamParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryStreamRepository>().addStream(
      params.categoryId,
      params.stream,
      params.notes,
      params.accessToken,
    );
  }
}