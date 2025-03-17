import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category.dart';

class DeleteCategoryParams {
  final int categoryId;
  final String accessToken;

  DeleteCategoryParams({required this.categoryId, required this.accessToken});
}

class DeleteCategoryUseCase extends UseCase<Either<Failure, bool>, DeleteCategoryParams> {
  @override
  Future<Either<Failure, bool>> call({DeleteCategoryParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryRepository>().deleteCategory(
      params.categoryId,
      params.accessToken,
    );
  }
}
