import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../data/categorystream/models/category_stream.dart';
import '../repositories/category_stream.dart';

class GetByDateCategoryStreamsByIdParams {
  final int userId;
  final DateTime date;
  final String accessToken;

  GetByDateCategoryStreamsByIdParams({
    required this.userId,
    required this.date,
    required this.accessToken,
  });
}

class GetByDateCategoryStreamsByIdUseCase extends UseCase<Either<Failure, List<CategoryStream>>,GetByDateCategoryStreamsByIdParams>{
  @override
  Future<Either<Failure, List<CategoryStream>>> call({
    GetByDateCategoryStreamsByIdParams? params,
  }) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryStreamRepository>().getByDateCategoryStreamsById(
      params.userId,
      params.date,
      params.accessToken,
    );
  }
}
