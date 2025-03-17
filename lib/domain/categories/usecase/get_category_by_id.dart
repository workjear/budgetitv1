import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/categories/models/category.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category.dart';

class GetCategoriesByIdParams {
  final int userId;
  final String accessToken;

  GetCategoriesByIdParams({required this.userId, required this.accessToken});
}

class GetCategoriesByIdUseCase extends UseCase<Either<Failure, List<Category>>, GetCategoriesByIdParams> {
  @override
  Future<Either<Failure, List<Category>>> call({
    GetCategoriesByIdParams? params,
  }) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryRepository>().getCategoriesById(
      params.userId,
      params.accessToken,
    );
  }
}
