import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../data/categorystream/models/category_stream.dart';
import '../repositories/category_stream.dart';

class GetCategoryStreamsByIdParams {
  final String userId;
  final String accessToken;

  GetCategoryStreamsByIdParams({required this.userId, required this.accessToken});
}

class GetCategoryStreamsByIdUseCase extends UseCase<Either<Failure, List<CategoryStream>>, GetCategoryStreamsByIdParams> {
  @override
  Future<Either<Failure, List<CategoryStream>>> call(
      {GetCategoryStreamsByIdParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    final id = int.tryParse(params.userId);
    return await sl<CategoryStreamRepository>().getCategoryStreamsById(
        id!,
        params.accessToken
    );
  }
}