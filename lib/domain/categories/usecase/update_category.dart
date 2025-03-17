import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category.dart';

class UpdateCategoryParams {
  final int categoryId;
  final String name;
  final String icon;
  final double? budget;
  final int type;
  final String accessToken;

  UpdateCategoryParams({
    required this.categoryId,
    required this.name,
    required this.icon,
    this.budget,
    required this.type,
    required this.accessToken,
  });
}

class UpdateCategoryUseCase
    extends UseCase<Either<Failure, String>, UpdateCategoryParams> {
  @override
  Future<Either<Failure, String>> call({UpdateCategoryParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryRepository>().updateCategory(
      params.categoryId,
      params.name,
      params.icon,
      params.budget,
      params.type,
      params.accessToken,
    );
  }
}