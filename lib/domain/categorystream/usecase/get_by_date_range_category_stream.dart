import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../data/categorystream/models/category_stream.dart';
import '../repositories/category_stream.dart';

class GetByDateRangeCategoryStreamsByIdParams {
  final int userId;
  final DateTime start;
  final DateTime end;
  final String accessToken;

  GetByDateRangeCategoryStreamsByIdParams({required this.userId, required this.accessToken, required this.start, required this.end});
}

class GetByDateRangeCategoryStreamUseCase extends UseCase<Either<Failure, List<CategoryStream>>, GetByDateRangeCategoryStreamsByIdParams> {
  @override
  Future<Either<Failure, List<CategoryStream>>> call(
      {GetByDateRangeCategoryStreamsByIdParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryStreamRepository>().getByDateRangeCategoryStreamsById(
        params.userId,
        params.start,
        params.end,
        params.accessToken
    );
  }
}