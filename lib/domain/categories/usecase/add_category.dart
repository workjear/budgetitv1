import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/category.dart';

class AddCategoryParams {
  final int userId;
  final String name;
  final String icon;
  final int type;
  final String accessToken;

  AddCategoryParams({
    required this.userId,
    required this.name,
    required this.icon,
    required this.type,
    required this.accessToken,
  });
}

class AddCategoryUseCase extends UseCase<Either<Failure, String>, AddCategoryParams> {
  @override
  Future<Either<Failure, String>> call({AddCategoryParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<CategoryRepository>().addCategory(
      params.userId,
      params.name,
      params.icon,
      params.type,
      params.accessToken,
    );
  }
}