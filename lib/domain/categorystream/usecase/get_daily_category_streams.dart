import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../data/categorystream/models/category_stream.dart';
import '../repositories/category_stream.dart';

class GetDailyCategoryStreamsByIdParams {
  final int userId;
  final String accessToken;

  GetDailyCategoryStreamsByIdParams({required this.userId, required this.accessToken});
}

class GetDailyCategoryStreamsByIdUseCase extends UseCase<Either<Failure, List<CategoryStream>>, GetDailyCategoryStreamsByIdParams> {
  @override
  Future<Either<Failure, List<CategoryStream>>> call(
      {GetDailyCategoryStreamsByIdParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryStreamRepository>().getDailyCategoryStreamsById(
        params.userId,
        params.accessToken
    );
  }
}